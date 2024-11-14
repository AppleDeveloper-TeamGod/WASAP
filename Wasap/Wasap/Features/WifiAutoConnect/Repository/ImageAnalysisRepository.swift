//
//  ImageAnalysisRepository.swift
//  Wasap
//
//  Created by Chang Jonghyeon on 10/6/24.
//

import RxSwift
import Vision

public protocol ImageAnalysisRepository {
    func performOCR(from imageData: Data) -> Single<OCRResultVO>

}

public final class DefaultImageAnalysisRepository: ImageAnalysisRepository {
    let idKeywords: [String] = ["ssid", "SSID", "ID", "Id", "iD", "id", "I/D", "I.D", "1D", "1.D", "아이디", "1b", "이름", "무선랜 이름", "무선랜이름", "1.0", "10", "Network", "NETWORK", "network", "네트워크",  "WIFI", "Wifi", "WiFi", "wifi", "Wi-Fi", "와이파이"]
    let pwKeywords: [String] = ["PW", "Pw", "pW", "pw", "pass", "Pass", "PASS", "password", "Password", "PASSWORD", "패스워드", "암호", "무선랜 암호", "무선랜암호", "P.W", "PV", "P/W", "P\\A", "P1A", "비밀번호", "비번"]

    public init() {}

    public func performOCR(from imageData: Data) -> Single<OCRResultVO> {
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

            let englishRequest = self.createTextRequest(for: "en")
            let koreanRequest = self.createTextRequest(for: "ko")

            let requestHandler = VNImageRequestHandler(cgImage: cgImage,
                                                       orientation: orientation,
                                                       options: [:])
            do {
                try requestHandler.perform([englishRequest/*, koreanRequest*/])

                if let result = self.handleOCRResults([englishRequest/*, koreanRequest*/]) {
                    single(.success(result))
                } else {
                    single(.failure(ImageAnalysisError.ocrFailed("Failed to process OCR results")))
                }

            } catch {
                single(.failure(ImageAnalysisError.ocrFailed("Failed to perform OCR: \(error.localizedDescription)")))
            }

            return Disposables.create()
        }
    }

    private func createTextRequest(for language: String) -> VNRecognizeTextRequest {
        let request = VNRecognizeTextRequest()
        request.recognitionLanguages = [language]
        request.usesLanguageCorrection = true
        request.recognitionLevel = .accurate
        request.customWords = ["ID", "PW"]
        return request
    }

    private func handleOCRResults(_ requests: [VNRequest]) -> OCRResultVO? {
        var ssidBoundingBox: CGRect? = nil
        var passwordBoundingBox: CGRect? = nil
        var ssidText: String? = nil
        var passwordText: String? = nil

        let allObservations = requests.compactMap { $0.results as? [VNRecognizedTextObservation] }.flatMap { $0 }

        let extractedBoxes = self.filterAndExtractTextBoxes(allObservations)

        // 1. ID(또는 PW) key와 value가 가로로 나란한 경우
        var ssidBox: (CGRect, String)?
        if let firstIDBox = extractedBoxes.idBoxes.first {
            if firstIDBox.content.isEmpty {
                ssidBox = findClosestRightText(for: extractedBoxes.idBoxes.map { $0.labelBox }, in: extractedBoxes.otherBoxes)
            } else {
                ssidBox = (firstIDBox.contentBox, firstIDBox.content)
            }
        }

        var passwordBox: (CGRect, String)?
        if let firstPWBox = extractedBoxes.pwBoxes.first {
            if firstPWBox.content.isEmpty {
                passwordBox = findClosestRightText(for: extractedBoxes.pwBoxes.map { $0.labelBox }, in: extractedBoxes.otherBoxes)
            } else {
                passwordBox = (firstPWBox.contentBox, firstPWBox.content)
            }
        }

        // 2. ID(또는 PW) key와 value가 세로로 나란한 경우
        if (ssidBox == nil) || (ssidBox?.1 == "") {
            ssidBox = findClosestBelowText(for: extractedBoxes.idBoxes.map { $0.labelBox }, in: extractedBoxes.otherBoxes)
        }
        if (passwordBox == nil) || (passwordBox?.1 == "") {
            passwordBox = findClosestBelowText(for: extractedBoxes.pwBoxes.map { $0.labelBox }, in: extractedBoxes.otherBoxes)
        }

        let delimiters = CharacterSet(charactersIn: "/,")

        if let ssidBox = ssidBox {
            let ssidValue = ssidBox.1.components(separatedBy: delimiters).first ?? ssidBox.1
            ssidText = ssidValue.replacingOccurrences(of: " ", with: "")
            ssidBoundingBox = ssidBox.0
        }

        if let passwordBox = passwordBox {
            let passwordValue = passwordBox.1.components(separatedBy: delimiters).first ?? passwordBox.1
            passwordText = passwordValue.replacingOccurrences(of: " ", with: "")
            passwordBoundingBox = passwordBox.0
        }

        return OCRResultVO(ssidBoundingBox: ssidBoundingBox, passwordBoundingBox: passwordBoundingBox, ssid: ssidText, password: passwordText)
    }

    private func filterAndExtractTextBoxes(_ observations: [VNRecognizedTextObservation]) -> ExtractedBoxes {
        var idBoxes: [KeywordBox] = []
        var pwBoxes: [KeywordBox] = []
        var otherBoxes: [(rect: CGRect, text: String)] = []

        for observation in observations {
            guard let topCandidate = observation.topCandidates(1).first else { continue }
            let originalText = topCandidate.string
            let boundingBox = observation.boundingBox

            let keywordBox = self.identifyKeyword(originalText: originalText, boundingBox: boundingBox)

            switch keywordBox.label {
            case "ID":
                idBoxes.append(keywordBox)
            case "PW":
                pwBoxes.append(keywordBox)
            default:
                otherBoxes.append((keywordBox.contentBox, keywordBox.content))

            }
        }

        idBoxes.sort { $0.index! < $1.index! }
        pwBoxes.sort { $0.index! < $1.index! }

        return ExtractedBoxes(idBoxes: idBoxes, pwBoxes: pwBoxes, otherBoxes: otherBoxes)
    }

    private func identifyKeyword(originalText: String, boundingBox: CGRect) -> KeywordBox {

        let (keyword, cleanedText, index) = replaceDelimiterAfterKeyword(in: originalText, keywords: idKeywords + pwKeywords)

        // ID or PW 키워드가 없는 경우 처리
        guard let keyword = keyword else {
//            Log.print("원본텍스트:\(originalText), 기타텍스트:\(cleanedText)")
            return KeywordBox(label: "", content: cleanedText, contentBox: boundingBox, labelBox: boundingBox, index: nil)
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
//            Log.print("원본텍스트:\(originalText), 분리된텍스트:'\(keyword)' + '\(value)'")
            return KeywordBox(label: "ID", content: value, contentBox: valueBox, labelBox: keywordBox, index: index)

        } else if pwKeywords.contains(keyword) {
//            Log.print("원본텍스트:\(originalText), 분리된텍스트:'\(keyword)' + '\(value)'")
            return KeywordBox(label: "PW", content: value, contentBox: valueBox, labelBox: keywordBox, index: index)
        }

        // 컴파일러 요구 사항에 따른 디폴트 반환값
        return KeywordBox(label: "", content: cleanedText, contentBox: boundingBox, labelBox: boundingBox, index: nil)
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



public final class QuickImageAnalysisRepository: ImageAnalysisRepository {
    let idKeywords: [String] = ["ssid", "SSID", "ID", "Id", "iD", "id", "I/D", "I.D", "1D", "1.D", "아이디", "1b", "이름", "무선랜 이름", "무선랜이름", "1.0", "10", "Network", "NETWORK", "network", "네트워크",  "WIFI", "Wifi", "WiFi", "wifi", "Wi-Fi", "와이파이"]
    let pwKeywords: [String] = ["PW", "Pw", "pW", "pw", "pass", "Pass", "PASS", "password", "Password", "PASSWORD", "패스워드", "암호", "무선랜 암호", "무선랜암호", "P.W", "PV", "P/W", "P\\A", "P1A", "비밀번호", "비번"]

    private let englishRequest = createTextRequest(for: "en")

    public init() {}

    public func performOCR(from imageData: Data) -> Single<OCRResultVO> {
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


            let requestHandler = VNImageRequestHandler(cgImage: cgImage,
                                                       orientation: orientation,
                                                       options: [:])
            Task {
                do {
                    try requestHandler.perform([self.englishRequest])

                    let result = await self.handleOCRResults([self.englishRequest])
                    guard let result else {
                        single(.failure(ImageAnalysisError.ocrFailed("Failed to process OCR results")))
                        return
                    }
                    single(.success(result))
                } catch {
                    single(.failure(ImageAnalysisError.ocrFailed("Failed to perform OCR: \(error.localizedDescription)")))
                }

            }

            return Disposables.create()
        }
    }

    static private func createTextRequest(for language: String) -> VNRecognizeTextRequest {
        let request = VNRecognizeTextRequest()
        request.recognitionLanguages = [language]
        request.usesLanguageCorrection = true
        request.recognitionLevel = .accurate
        request.customWords = ["ID", "PW"]
        return request
    }

    private func handleOCRResults(_ requests: [VNRequest]) async -> OCRResultVO? {

        let allObservations = requests.compactMap { $0.results as? [VNRecognizedTextObservation] }.flatMap { $0 }

        let extractedBoxes = self.filterAndExtractTextBoxes(allObservations)

        let delimiters = CharacterSet(charactersIn: "/,")

        async let ssidTask: (rect: CGRect, text: String)? = await { () async -> (rect: CGRect, text: String)? in
            if let ssid = ssidBox(with: extractedBoxes) {
                let separatedSsidValue = ssid.1.components(separatedBy: delimiters).first ?? ssid.1
                let ssidText: String = separatedSsidValue.replacingOccurrences(of: " ", with: "")
                return (ssid.0, ssidText)
            } else {
                return nil
            }
        }()

        async let passwordTask: (rect: CGRect, text: String)? = await { () async -> (rect: CGRect, text: String)? in
            if let password = passwordBox(with: extractedBoxes) {
                let separatedSsidValue = password.1.components(separatedBy: delimiters).first ?? password.1
                let passwordText: String = separatedSsidValue.replacingOccurrences(of: " ", with: "")
                return (password.0, passwordText)
            } else {
                return nil
            }
        }()


        let ssidResult = await ssidTask
        let passwordResult = await passwordTask

        return OCRResultVO(ssidBoundingBox: ssidResult?.rect, passwordBoundingBox: passwordResult?.rect, ssid: ssidResult?.text, password: passwordResult?.text)
    }

    private func filterAndExtractTextBoxes(_ observations: [VNRecognizedTextObservation]) -> ExtractedBoxes {
        var idBoxes: [KeywordBox] = []
        var pwBoxes: [KeywordBox] = []
        var otherBoxes: [(rect: CGRect, text: String)] = []

        for observation in observations {
            guard let topCandidate = observation.topCandidates(1).first else { continue }
            let originalText = topCandidate.string
            let boundingBox = observation.boundingBox

            let keywordBox = self.identifyKeyword(originalText: originalText, boundingBox: boundingBox)

            switch keywordBox.label {
            case "ID":
                idBoxes.append(keywordBox)
            case "PW":
                pwBoxes.append(keywordBox)
            default:
                otherBoxes.append((keywordBox.contentBox, keywordBox.content))

            }
        }

        idBoxes.sort { $0.index! < $1.index! }
        pwBoxes.sort { $0.index! < $1.index! }

        return ExtractedBoxes(idBoxes: idBoxes, pwBoxes: pwBoxes, otherBoxes: otherBoxes)
    }

    private func ssidBox(with extractedBoxes: ExtractedBoxes) -> (rect: CGRect, text: String)? {
        var foundBox: (rect: CGRect, text: String)? = nil
        // 1. ID(또는 PW) key와 value가 가로로 나란한 경우
        if let firstIDBox = extractedBoxes.idBoxes.first {
            if firstIDBox.content.isEmpty {
                foundBox = self.findClosestRightText(for: extractedBoxes.idBoxes.map { $0.labelBox }, in: extractedBoxes.otherBoxes)
            } else {
                foundBox = (firstIDBox.contentBox, firstIDBox.content)
            }
        }
        // 2. ID(또는 PW) key와 value가 세로로 나란한 경우
        if (foundBox == nil) || (foundBox?.1 == "") {
            foundBox = self.findClosestBelowText(for: extractedBoxes.idBoxes.map { $0.labelBox }, in: extractedBoxes.otherBoxes)
        }
        return foundBox
    }

    private func passwordBox(with extractedBoxes: ExtractedBoxes) -> (rect: CGRect, text: String)? {
        var foundBox: (rect: CGRect, text: String)? = nil
        // 1. ID(또는 PW) key와 value가 가로로 나란한 경우
        if let firstPWBox = extractedBoxes.pwBoxes.first {
            if firstPWBox.content.isEmpty {
                foundBox = self.findClosestRightText(for: extractedBoxes.pwBoxes.map { $0.labelBox }, in: extractedBoxes.otherBoxes)
            } else {
                foundBox = (firstPWBox.contentBox, firstPWBox.content)
            }
        }
        // 2. ID(또는 PW) key와 value가 세로로 나란한 경우
        if (foundBox == nil) || (foundBox?.1 == "") {
            foundBox = self.findClosestBelowText(for: extractedBoxes.pwBoxes.map { $0.labelBox }, in: extractedBoxes.otherBoxes)
        }
        return foundBox
    }

    private func identifyKeyword(originalText: String, boundingBox: CGRect) -> KeywordBox {

        let (keyword, cleanedText, index) = replaceDelimiterAfterKeyword(in: originalText, keywords: idKeywords + pwKeywords)

        // ID or PW 키워드가 없는 경우 처리
        guard let keyword = keyword else {
            //            Log.print("원본텍스트:\(originalText), 기타텍스트:\(cleanedText)")
            return KeywordBox(label: "", content: cleanedText, contentBox: boundingBox, labelBox: boundingBox, index: nil)
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
            //            Log.print("원본텍스트:\(originalText), 분리된텍스트:'\(keyword)' + '\(value)'")
            return KeywordBox(label: "ID", content: value, contentBox: valueBox, labelBox: keywordBox, index: index)

        } else if pwKeywords.contains(keyword) {
            //            Log.print("원본텍스트:\(originalText), 분리된텍스트:'\(keyword)' + '\(value)'")
            return KeywordBox(label: "PW", content: value, contentBox: valueBox, labelBox: keywordBox, index: index)
        }

        // 컴파일러 요구 사항에 따른 디폴트 반환값
        return KeywordBox(label: "", content: cleanedText, contentBox: boundingBox, labelBox: boundingBox, index: nil)
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
