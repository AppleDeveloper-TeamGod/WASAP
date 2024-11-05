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
    let idKeywords: [String] = ["ssid", "SSID", "ID", "Id", "iD", "id", "I/D", "I.D", "1D", "아이디", "1b", "이름", "무선랜 이름", "무선랜이름", "1.0", "10", "Network", "NETWORK", "network", "네트워크",  "WIFI", "Wifi", "WiFi", "wifi", "Wi-Fi", "와이파이"]
    let pwKeywords: [String] = ["PW", "Pw", "pW", "pw", "pass", "Pass", "PASS", "password", "Password", "PASSWORD", "패스워드", "암호", "무선랜 암호", "무선랜암호", "P.W", "PV", "P/W", "P\\A", "P1A", "비밀번호", "비번"]

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

        // 1. ID(또는 PW) key와 value가 가로로 나란한 경우
        var ssidBox = idBoxes.first?.1 == "" ? findClosestRightText(for: idBoxes.map { $0.2 }, in: otherBoxes) : idBoxes.first.map { ($0.0, $0.1) }
        var passwordBox = pwBoxes.first?.1 == "" ? findClosestRightText(for: pwBoxes.map { $0.2 }, in: otherBoxes) : pwBoxes.first.map { ($0.0, $0.1) }

        // 2. ID(또는 PW) key와 value가 세로로 나란한 경우
        if (ssidBox == nil) || (ssidBox?.1 == "") {
            ssidBox = findClosestBelowText(for: idBoxes.map { $0.2 }, in: otherBoxes)
        }
        if (passwordBox == nil) || (passwordBox?.1 == "") {
            passwordBox = findClosestBelowText(for: pwBoxes.map { $0.2 }, in: otherBoxes)
        }

        let delimiters = CharacterSet(charactersIn: "/,")

        if let ssidBox = ssidBox {
            boundingBoxes.append(ssidBox.0)
            let ssidValue = ssidBox.1.components(separatedBy: delimiters).first ?? ssidBox.1
            self.ssidText = ssidValue.replacingOccurrences(of: " ", with: "")
        }

        if let passwordBox = passwordBox {
            boundingBoxes.append(passwordBox.0)
            let passwordValue = passwordBox.1.components(separatedBy: delimiters).first ?? passwordBox.1
            self.passwordText = passwordValue.replacingOccurrences(of: " ", with: "")
        }

        DispatchQueue.main.async {
            single(.success((self.boundingBoxes, self.ssidText, self.passwordText)))
        }
    }

    private func filterAndExtractTextBoxes(_ observations: [VNRecognizedTextObservation]) -> ([(CGRect, String, CGRect)], [(CGRect, String, CGRect)], [(CGRect, String)]) {
        var idBoxes: [(CGRect, String, CGRect, Int?)] = []
        var pwBoxes: [(CGRect, String, CGRect, Int?)] = []
        var otherBoxes: [(CGRect, String)] = []

        for observation in observations {
            guard let topCandidate = observation.topCandidates(1).first else { continue }
            let originalText = topCandidate.string
            let boundingBox = observation.boundingBox

            let (label, content, contentBox, labelBox, index) = self.identifyKeyword(originalText: originalText, boundingBox: boundingBox)

            switch label {
            case "ID":
                idBoxes.append((contentBox, content, labelBox, index))
            case "PW":
                pwBoxes.append((contentBox, content, labelBox, index))
            default:
                otherBoxes.append((contentBox, content))

            }
        }

        idBoxes.sort { $0.3! < $1.3! }
        pwBoxes.sort { $0.3! < $1.3! }

        return (idBoxes.map { ($0.0, $0.1, $0.2) }, pwBoxes.map { ($0.0, $0.1, $0.2) }, otherBoxes.map { ($0.0, $0.1) })
    }

    private func identifyKeyword(originalText: String, boundingBox: CGRect) -> (String, String, CGRect, CGRect, Int?) {

        let (keyword, cleanedText, index) = replaceDelimiterAfterKeyword(in: originalText, keywords: idKeywords + pwKeywords)

        // ID or PW 키워드가 없는 경우 처리
        guard let keyword = keyword else {
            Log.print("원본텍스트:\(originalText), 기타텍스트:\(cleanedText)")
            return ("", cleanedText, boundingBox, boundingBox, nil)
        }

        // ID or PW 키워드가 있는 경우 처리
        let value = cleanedText
        let valueBox = self.splitBoundingBox(originalBox: boundingBox, splitFactor: CGFloat(1 - Double(value.count) / Double(originalText.count)))

        let keywordBox = CGRect(
            x: boundingBox.minX,
            y: boundingBox.minY,
            width: boundingBox.width - valueBox.width,
            height: boundingBox.height
        )

        // ID와 PW 구분에 따라 처리
        if idKeywords.contains(keyword) {
            Log.print("원본텍스트:\(originalText), 분리된텍스트:'\(keyword)' + '\(value)'")
            return ("ID", value, valueBox, keywordBox, index)

        } else if pwKeywords.contains(keyword) {
            Log.print("원본텍스트:\(originalText), 분리된텍스트:'\(keyword)' + '\(value)'")
            return ("PW", value, valueBox, keywordBox, index)
        }

        // 컴파일러 요구 사항에 따른 디폴트 반환값
        return ("", cleanedText, boundingBox, boundingBox, nil)
    }

    private func replaceDelimiterAfterKeyword(in text: String, keywords: Array<String>) -> (String?, String, Int?) {
        // 각 키워드를 순회하며 해당 키워드가 있는 위치를 찾습니다.
        for (index, keyword) in keywords.enumerated() {
            if let range = text.range(of: "\\b\(keyword)\\b", options: .regularExpression) {
                // 키워드 뒤의 텍스트 추출
                var modifiedSuffix = text[range.upperBound...].trimmingCharacters(in: .whitespaces)

                // 첫 번째 문자가 특수 문자일 경우, 알파벳이나 숫자가 나올 때까지 공백으로 대체
                while let firstChar = modifiedSuffix.first, ":-._\\/|)]}".contains(firstChar) {
                    modifiedSuffix.replaceSubrange(modifiedSuffix.startIndex...modifiedSuffix.startIndex, with: " ")

                    modifiedSuffix = modifiedSuffix.trimmingCharacters(in: .whitespaces)
                }
                return (keyword, modifiedSuffix.trimmingCharacters(in: .whitespaces), index)

            }
        }

        // 키워드가 발견되지 않은 경우
        return (nil, text, nil)
    }

    private func splitBoundingBox(originalBox: CGRect, splitFactor: CGFloat) -> CGRect {
        let newWidth = originalBox.width * (1 - splitFactor)
        let newX = originalBox.minX + (originalBox.width * splitFactor)
        return CGRect(x: newX, y: originalBox.minY, width: newWidth, height: originalBox.height)
    }

    private func findClosestRightText(for sourceBoxes: [CGRect], in otherBoxes: [(CGRect, String)]) -> (CGRect, String)? {
        guard let sourceBox = sourceBoxes.first else { return nil }

        let yWeight: CGFloat = 1.0

        var closestRightText: String = ""
        var closestRightBox: CGRect?
        var minDistance = CGFloat.greatestFiniteMagnitude

        for (candidateBox, candidateText) in otherBoxes {
            if candidateBox.minX > sourceBox.midX && candidateBox.minY < sourceBox.maxY && candidateBox.maxY > sourceBox.minY {

                let deltaX = candidateBox.minX - sourceBox.maxX
                let deltaY = (candidateBox.midY - sourceBox.midY) * yWeight
                let distance = sqrt(pow(deltaX, 2) + pow(deltaY, 2))

                if distance < minDistance {
                    closestRightText = candidateText
                    closestRightBox = candidateBox
                    minDistance = distance
                }
            }
        }

        return closestRightBox.map { ($0, closestRightText) }
    }

    private func findClosestBelowText(for sourceBoxes: [CGRect], in otherBoxes: [(CGRect, String)]) -> (CGRect, String)? {
        guard let sourceBox = sourceBoxes.first else { return nil }
        
        let xWeight: CGFloat = 1.0

        var closestBelowText: String = ""
        var closestBelowBox: CGRect?
        var minDistance = CGFloat.greatestFiniteMagnitude

        for (candidateBox, candidateText) in otherBoxes {
            if candidateBox.maxY < sourceBox.midY && candidateBox.maxX > sourceBox.minX && candidateBox.minX < sourceBox.maxX {

                let deltaX = (candidateBox.midX - sourceBox.midX) * xWeight
                let deltaY = candidateBox.maxY - sourceBox.minY
                let distance = sqrt(pow(deltaX, 2) + pow(deltaY, 2))

                if distance < minDistance {
                    closestBelowText = candidateText
                    closestBelowBox = candidateBox
                    minDistance = distance
                }
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
}


