//
//  ImageAnalysisRepository.swift
//  Wasap
//
//  Created by Chang Jonghyeon on 10/6/24.
//

import RxSwift
import Vision

public protocol ImageAnalysisRepository {
    func performOCR(from imageData: Data) -> Single<([CGRect], String, String)>

}

public class DefaultImageAnalysisRepository: ImageAnalysisRepository {
    let idKeywords: Set<String> = ["ID", "Id", "iD", "id", "WIFI", "Wifi", "WiFi", "wifi", "Wi-Fi", "Network", "NETWORK", "network", "ssid", "SSID", "와이파이", "네트워크", "I.D", "1D", "아이디"]
    let pwKeywords: Set<String> = ["PW", "Pw", "pW", "pw", "pass", "Pass", "PASS", "password", "Password", "PASSWORD", "패스워드", "암호", "P.W", "PV", "P/W", "비밀번호", "비번"]

    var ssidText: String = ""
    var passwordText: String = ""
    var boundingBoxes: [CGRect] = []

    public init() {}

    public func performOCR(from imageData: Data) -> Single<([CGRect], String, String)> {
        return Single.create { [weak self] single in
            guard let self = self else {
                single(.failure(ImageAnalysisError.ocrFailed("Self not found")))
                return Disposables.create()
            }

            guard let cgImage = self.convertDataToCGImage(imageData) else {
                single(.failure(ImageAnalysisError.invalidImage))
                return Disposables.create()
            }

            let orientation = self.extractOrientation(from: imageData)
            let request = VNRecognizeTextRequest { [weak self] request, error in
                guard let self = self else { return }
                self.handleOCRResults(request: request, error: error, single: single)
            }

            request.recognitionLanguages = ["ko", "en"]
            request.usesLanguageCorrection = true

            let requestHandler = VNImageRequestHandler(cgImage: cgImage,
                                                       orientation: orientation,
                                                       options: [:])
            do {
                try requestHandler.perform([request])
            } catch {
                single(.failure(ImageAnalysisError.ocrFailed("Failed to perform OCR: \(error.localizedDescription)")))
            }

            return Disposables.create()
        }
    }

    private func handleOCRResults(request: VNRequest, error: Error?, single: @escaping (SingleEvent<([CGRect], String, String)>) -> Void) {
        if let error = error {
            single(.failure(ImageAnalysisError.ocrFailed(error.localizedDescription)))
            return
        }

        guard let results = request.results as? [VNRecognizedTextObservation] else {
            single(.failure(ImageAnalysisError.ocrFailed("No results found")))
            return
        }

        let (idBoxes, pwBoxes, otherBoxes) = self.filterAndExtractTextBoxes(results)

        // 우선 `idValueBox`와 `pwValueBox`를 사용하고, 없을 경우 otherBoxes에서 수직 하단 텍스트를 찾습니다.
        let ssidBox = idBoxes.first?.1 == "" ? findClosestBelowText(for: idBoxes.map { $0.0 }, in: otherBoxes) : idBoxes.first
        let passwordBox = pwBoxes.first?.1 == "" ? findClosestBelowText(for: pwBoxes.map { $0.0 }, in: otherBoxes) : pwBoxes.first

        if let ssidBox = ssidBox {
            boundingBoxes.append(ssidBox.0)
            self.ssidText = ssidBox.1
        }

        if let passwordBox = passwordBox {
            boundingBoxes.append(passwordBox.0)
            self.passwordText = passwordBox.1
        }

        DispatchQueue.main.async {
            single(.success((self.boundingBoxes, self.ssidText, self.passwordText)))
        }

        /**
        // observation별로 텍스트 정리하고 앞에 ID 또는 PW가 있는지 보고
        // ID있으면,
        // 그 전체 boundingBox(ID: 올레기가)를 idBoxes에 넣고
        // (그 전체 boundingBox, "ID")를 boxes에 넣고
        // boundingBox를 쪼개서
        // (내용물 박스, 내용물 텍스트)를 boxes에 넣는다.
        //
        //
        // 만약 ID, PW 없으면
        // (그 전체 boundingBox, 그 전체 텍스트)를 boxes에 넣는다.
        for observation in results {
            print("--------------------------텍스트 분리----------------------------")
            if let topCandidate = observation.topCandidates(1).first {
                let originalString = topCandidate.string
                let boundingBox = observation.boundingBox

                // 1차: 공백 제거
                let noSpaceString = originalString.replacingOccurrences(of: " ", with: "")

                // 2차: 콜론(:) 및 하이픈(-) 제거
                let cleanedString = noSpaceString.replacingOccurrences(of: "[:\\-]", with: " ", options: .regularExpression)

                // 텍스트가 "ID" 또는 "PW"로 시작하는지 확인
                let components = cleanedString.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
                guard let firstWord = components.first.map(String.init) else { continue }

                if self.idKeywords.contains(firstWord) {
                    // "ID" 부분을 분리하고 나머지 텍스트와 나눔
                    let idText = firstWord
                    let remainingText = components.count > 1 ? String(components[1]) : ""

                    // "ID" 부분에 대한 Bounding Box 분리
                    let idBox = boundingBox
                    let remainingBox = self.splitBoundingBox(originalBox: boundingBox, splitFactor: CGFloat(1 - Double(remainingText.count)/Double(noSpaceString.count)))

                    idBoxes.append(idBox)
                    boxes.append((idBox, "ID"))

                    if !remainingText.isEmpty {
                        boxes.append((remainingBox, remainingText))
                    }

                    Log.print("원본텍스트:\(originalString), 분리된텍스트:'\(idText)' + '\(remainingText)'")

                } else if self.pwKeywords.contains(firstWord) {
                    // "PW" 부분을 분리하고 나머지 텍스트와 나눔
                    let pwText = firstWord
                    let remainingText = components.count > 1 ? String(components[1]) : ""

                    // "PW" 부분에 대한 Bounding Box 분리
                    let pwBox = boundingBox
                    let remainingBox = self.splitBoundingBox(originalBox: boundingBox, splitFactor: CGFloat(1 - Double(remainingText.count)/Double(noSpaceString.count)))

                    pwBoxes.append(pwBox)
                    boxes.append((pwBox, "PW"))

                    if !remainingText.isEmpty {
                        boxes.append((remainingBox, remainingText))
                    }

                    Log.print("원본텍스트:\(originalString), 분리된텍스트:'\(pwText)' + '\(remainingText)'")

                } else {
                    boxes.append((boundingBox, originalString))
                    Log.print("원본텍스트:\(originalString), 기타텍스트:\(cleanedString)")
                }
            }
        }
         */

        /**
        var extractedBoxes: [CGRect] = []

        // "ID"에 가장 가까운 Bounding Box(SSID 값, 보라색) 탐색 - PW는 제외
        for idBox in idBoxes {
            print("-----아이디박스----")
            if let closestBox = self.closestBoundingBox(from: idBox, in: boxes.filter { $0.1 != "ID" && $0.1 != "PW" }) {

                extractedBoxes.append(closestBox.0)
                self.ssidText = closestBox.1.replacingOccurrences(of: " ", with: "")
                Log.print("보라색박스(SSID 값 추정):\(self.ssidText)")

                let distance = self.distanceBetweenEdges(idBox, closestBox.0)
                print("ID 박스 CGRect: \(self.formatCGRect(idBox))")
                print("SSID 박스 CGRect: \(self.formatCGRect(closestBox.0))")
                print("ID 박스와 SSID 값의 거리: \(String(format: "%.3f", distance))")
            }
        }

        // "PW"에 가장 가까운 Bounding Box(Password 값, 연두색) 탐색 - ID와 SSID value 박스는 제외
        for pwBox in pwBoxes {
            print("-----비번박스----")
            if let closestBox = self.closestBoundingBox(from: pwBox, in: boxes.filter { box in
                box.1 != "ID" && box.1 != "PW" && extractedBoxes.first(where: { extractedBox in box.0 == extractedBox }) == nil }) {

                extractedBoxes.append(closestBox.0)
                self.passwordText = closestBox.1.replacingOccurrences(of: " ", with: "")
                Log.print("연두색박스(Password 값 추정):\(self.passwordText)")

                let distance = self.distanceBetweenEdges(pwBox, closestBox.0)
                print("PW 박스 CGRect: \(self.formatCGRect(pwBox))")
                print("Password 박스 CGRect: \(self.formatCGRect(closestBox.0))")
                print("PW 박스와 Password 값의 거리: \(String(format: "%.3f", distance))")
            }
        }

        DispatchQueue.main.async {
            self.boundingBoxes.append(contentsOf: extractedBoxes)
            single(.success((self.boundingBoxes, self.ssidText, self.passwordText)))
        }
         */
    }

    private func filterAndExtractTextBoxes(_ observations: [VNRecognizedTextObservation]) -> ([(CGRect, String)], [(CGRect, String)], [(CGRect, String)]) {
        var idBoxes: [(CGRect, String)] = []
        var pwBoxes: [(CGRect, String)] = []
        var otherBoxes: [(CGRect, String)] = []

        for observation in observations {
            guard let topCandidate = observation.topCandidates(1).first else { continue }
            let originalText = topCandidate.string
            let boundingBox = observation.boundingBox

            let (label, content, box) = self.identifyKeyword(originalText: originalText,
                                                             boundingBox: boundingBox)

            switch label {
            case "ID":
                idBoxes.append((box, content))
            case "PW":
                pwBoxes.append((box, content))
            default:
                otherBoxes.append((box, content))

            }
        }

        return (idBoxes, pwBoxes, otherBoxes)
    }

    private func identifyKeyword(originalText: String, boundingBox: CGRect) -> (String, String, CGRect) {
        // 1차: 공백 제거
        let noSpaceText = originalText.replacingOccurrences(of: " ", with: "")

        // 2차: 콜론(:) 및 하이픈(-) 제거
        let cleanedText = noSpaceText.replacingOccurrences(of: "[:\\-]", with: " ", options: .regularExpression)

        // 텍스트가 "ID" 또는 "PW"로 시작하는지 확인
        let components = cleanedText.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
        guard let firstWord = components.first.map(String.init) else { return ("", originalText, boundingBox) }

        if idKeywords.contains(firstWord) {
            let idValue = components.count > 1 ? String(components[1]) : ""
            let idValueBox = self.splitBoundingBox(originalBox: boundingBox, splitFactor: CGFloat(1 - Double(idValue.count)/Double(noSpaceText.count)))

            Log.print("원본텍스트:\(originalText), 분리된텍스트:'\(firstWord)' + '\(idValue)'")
            return ("ID", idValue, idValueBox)

        } else if pwKeywords.contains(firstWord) {
            let pwValue = components.count > 1 ? String(components[1]) : ""
            let pwValueBox = self.splitBoundingBox(originalBox: boundingBox, splitFactor: CGFloat(1 - Double(pwValue.count)/Double(noSpaceText.count)))

            Log.print("원본텍스트:\(originalText), 분리된텍스트:'\(firstWord)' + '\(pwValue)'")
            return ("PW", pwValue, pwValueBox)
        }

        Log.print("원본텍스트:\(originalText), 기타텍스트:\(cleanedText)")
        return ("", cleanedText, boundingBox)

    }

    private func splitBoundingBox(originalBox: CGRect, splitFactor: CGFloat) -> CGRect {
        let newWidth = originalBox.width * (1 - splitFactor)
        let newX = originalBox.minX + (originalBox.width * splitFactor)
        return CGRect(x: newX, y: originalBox.minY, width: newWidth, height: originalBox.height)
    }

    private func findClosestBelowText(for sourceBoxes: [CGRect], in otherBoxes: [(CGRect, String)]) -> (CGRect, String)? {
        guard let sourceBox = sourceBoxes.first else { return nil }

        var closestBelowText: String = ""
        var closestBelowBox: CGRect?
        var minDistance = CGFloat.greatestFiniteMagnitude

        for (candidateBox, candidateText) in otherBoxes {
            let distance = distanceBetweenEdges(sourceBox, candidateBox)

            if distance < minDistance && candidateBox.minY < sourceBox.minY {
                closestBelowText = candidateText
                closestBelowBox = candidateBox
                minDistance = distance
            }
        }

        return closestBelowBox.map { ($0, closestBelowText) }
    }

    // 이미지 Data 타입 -> CGImage 타입 변환
    private func convertDataToCGImage(_ data: Data) -> CGImage? {
        guard let dataProvider = CGDataProvider(data: data as CFData) else { return nil }
        return CGImage(jpegDataProviderSource: dataProvider, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
    }

    // 이미지 Data타입의 orientation 정보 추출
    private func extractOrientation(from imageData: Data) -> CGImagePropertyOrientation {
        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let orientationValue = properties[kCGImagePropertyOrientation] as? UInt32
        else {
            return .up
        }

        return CGImagePropertyOrientation(rawValue: orientationValue) ?? .up
    }

    private func distanceBetweenEdges(_ rect1: CGRect, _ rect2: CGRect) -> CGFloat {
        // X축 겹침 여부 확인: 두 사각형이 가로 방향으로 겹치지 않으면 수직 하단으로 간주하지 않음
        guard rect1.maxX >= rect2.minX && rect2.maxX >= rect1.minX else { return CGFloat.greatestFiniteMagnitude }

        // Y축 거리 계산
        if rect1.maxY <= rect2.minY {
            // 수직으로 겹치지 않는 경우: 두 사각형의 Y축 간격
            return rect2.minY - rect1.maxY
        } else {
            // 수직으로 겹치는 경우: 겹친 영역의 Y축 최소 거리
            return min(abs(rect1.minY - rect2.minY), abs(rect1.maxY - rect2.maxY))
        }
    }

    /**
    private func distanceBetweenEdges(_ rect1: CGRect, _ rect2: CGRect, yWeight: CGFloat = 2.0) -> CGFloat {
        // X축 최단 거리: 두 사각형이 겹치지 않으면 그 간격, 겹치면 0
        let dx = max(0, max(rect1.minX - rect2.maxX, rect2.minX - rect1.maxX))

        // Y축 최단 거리: 두 사각형이 겹치지 않으면 그 간격, 겹치면 0
        let dy = max(0, max(rect1.minY - rect2.maxY, rect2.minY - rect1.maxY))

        // minX끼리의 차이, maxX끼리의 차이
        let dxMin = abs(rect1.minX - rect2.minX)
        let dxMax = abs(rect1.maxX - rect2.maxX)

        // minY끼리의 차이, maxY끼리의 차이
        let dyMin = abs(rect1.minY - rect2.minY)
        let dyMax = abs(rect1.maxY - rect2.maxY)

        // X축에서 기존 dx와 minX끼리/maxX끼리 중 더 짧은 값 선택
        let finalDx = min(dx, dxMin, dxMax)

        // Y축에서 기존 dy와 minY끼리/maxY끼리 중 더 짧은 값 선택
        let finalDy = min(dy, dyMin, dyMax) * yWeight

        // 최종 거리 계산 (피타고라스 정리 사용)
        return sqrt(finalDx * finalDx + finalDy * finalDy)
    }
    */

    // CGRect를 소수점 셋째자리까지 포맷팅하는 함수
    private func formatCGRect(_ rect: CGRect) -> String {
        return String(format: "(x: %.3f, y: %.3f, width: %.3f, height: %.3f)", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)
    }

    /**
    private func closestBoundingBox(from sourceBox: CGRect, in boxes: [(CGRect, String)]) -> (CGRect, String)? {
        return boxes.min { distanceBetweenEdges($0.0, sourceBox) < distanceBetweenEdges($1.0, sourceBox) }
    }
    */
}


