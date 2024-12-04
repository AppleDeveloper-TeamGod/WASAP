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
//    let idKeywords: [String] = ["ssid", "SSID", "ID", "Id", "iD", "id", "I/D", "I.D", "1D", "1.D", "아이디", "1b", "이름", "무선랜 이름", "무선랜이름", "1.0", "10", "Network", "NETWORK", "network", "네트워크",  "WIFI", "Wifi", "WiFi", "wifi", "Wi-Fi", "와이파이"]
//    let pwKeywords: [String] = ["PW", "Pw", "pW", "pw", "pass", "Pass", "PASS", "password", "Password", "PASSWORD", "패스워드", "암호", "무선랜 암호", "무선랜암호", "P.W", "PV", "P/W", "P\\A", "P1A", "비밀번호", "비번"]

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
                ssidBox = findClosestRightText(for: extractedBoxes.idBoxes.map { $0.keywordBox ?? $0.contentBox }, in: extractedBoxes.otherBoxes)
                print("ssid findClosestRightText:\(ssidBox?.1)|| \(ssidBox?.0)||\(extractedBoxes.idBoxes.first?.keyword)||\(extractedBoxes.idBoxes.first?.keywordBox)")
            } else {
                ssidBox = (firstIDBox.contentBox, firstIDBox.content)
                print("ssid in!! @first: \(ssidBox?.1)")
            }
        }

        var passwordBox: (CGRect, String)?
        if let firstPWBox = extractedBoxes.pwBoxes.first {
            if firstPWBox.content.isEmpty {
                passwordBox = findClosestRightText(for: extractedBoxes.pwBoxes.map { $0.keywordBox ?? $0.contentBox }, in: extractedBoxes.otherBoxes)
                print("pass findClosestRightText: \(passwordBox?.1)|| \(passwordBox?.0)||\(extractedBoxes.pwBoxes.first?.keyword)||\(extractedBoxes.pwBoxes.first?.keywordBox)")
            } else {
                passwordBox = (firstPWBox.contentBox, firstPWBox.content)
                print("pass in!! @first: \(passwordBox?.1)")
            }
        } else if ssidBox != nil && ssidBox?.1 != "" {
            passwordBox = findClosestBelowText(for: [ssidBox!.0], in: extractedBoxes.otherBoxes)
            print("pass findClosestBelowText in ssid O & pass X @first: \(passwordBox?.1)")
//            print("other:\(extractedBoxes.otherBoxes.first?.1)")
//            print("🐰ssidBox1:\(ssidBox?.1)")
//            print("🐰ssidBox0:\(ssidBox?.0)")
//            print("🥝passwordBox:\(passwordBox?.1)")
        }

        // 2. ID(또는 PW) key와 value가 세로로 나란한 경우
        if (ssidBox == nil) || (ssidBox?.1 == "") {
            ssidBox = findClosestBelowText(for: extractedBoxes.idBoxes.map { $0.keywordBox ?? $0.contentBox }, in: extractedBoxes.otherBoxes)
            print("ssid findClosestBelowText: \(ssidBox?.1)")
        }
        if (passwordBox == nil) || (passwordBox?.1 == "") {
            passwordBox = findClosestBelowText(for: extractedBoxes.pwBoxes.map { $0.keywordBox ?? $0.contentBox }, in: extractedBoxes.otherBoxes)
            print("pass findClosestBelowText: \(passwordBox?.1)")
            if let ssidBox = ssidBox {
                if (passwordBox == nil || passwordBox?.1 == "") && ssidBox.1 != "" {
                    passwordBox = findClosestBelowText(for: [ssidBox.0], in: extractedBoxes.otherBoxes)
                    print("pass findClosestBelowText in ssid O & pass X @Last: \(passwordBox?.1)")
                }
            }
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

            let keywordBoxes = self.identifyKeyword(originalText: originalText, boundingBox: boundingBox)

            for keywordBox in keywordBoxes {
                switch keywordBox.label {
                case "ID":
                    idBoxes.append(keywordBox)
                case "PW":
                    pwBoxes.append(keywordBox)
                default:
                    otherBoxes.append((keywordBox.contentBox, keywordBox.content))
                }
            }
        }

//        idBoxes.sort { $0.keyword! < $1.keyword! }
//        pwBoxes.sort { $0.keyword! < $1.keyword! }

        idBoxes.sort {
            if $0.keyword! == $1.keyword! {
                return !$0.content.isEmpty && $1.content.isEmpty
            }
            let isFirstWiFi = $0.keyword!.wholeMatch(of: RegexManager.shared.wifiRegex) != nil
            let isSecondWiFi = $1.keyword!.wholeMatch(of: RegexManager.shared.wifiRegex) != nil
            if isFirstWiFi != isSecondWiFi {
                // Wi-Fi 관련 키워드가 있으면 뒤로 보냄
                return !isFirstWiFi
            }
            return $0.keyword! < $1.keyword!
        }

        pwBoxes.sort {
            if $0.keyword! == $1.keyword! {
                return !$0.content.isEmpty && $1.content.isEmpty
            }
            return $0.keyword! < $1.keyword!
        }

        return ExtractedBoxes(idBoxes: idBoxes, pwBoxes: pwBoxes, otherBoxes: otherBoxes)
    }

    private func identifyKeyword(originalText: String, boundingBox: CGRect) -> [KeywordBox] {
        let regexManager = RegexManager.shared
        var keywordBoxes: [KeywordBox] = []

        if let match = originalText.wholeMatch(of: regexManager.ktWifiRegex) ??
                       originalText.wholeMatch(of: regexManager.skWifiRegex) ??
                       originalText.wholeMatch(of: regexManager.lgWifiRegex) {
            let value = String(match.1)
                .trimmingCharacters(in: .whitespaces)
                .replacing(/[\-.\s]/, with: "_")
                .replacing(/_+/, with: "_")
            let valueBox = self.splitBoundingBox(originalBox: boundingBox, splitFactor: CGFloat(1 - Double(String(match.1).count) / Double(originalText.count)))

            keywordBoxes.append(KeywordBox(label: "ID", content: value, contentBox: valueBox, keyword: "", keywordBox: nil))

        } else if let match = originalText.wholeMatch(of: regexManager.idRegex) {
            let keyword = String(match.1)
            let value = String(match.2).trimmingCharacters(in: .whitespaces)
            let valueBox = self.splitBoundingBox(originalBox: boundingBox, splitFactor: CGFloat(1 - Double(String(match.2).count) / Double(originalText.count)))
            let keywordBox = CGRect(
                x: boundingBox.minX,
                y: boundingBox.minY,
                width: boundingBox.width - valueBox.width,
                height: boundingBox.height
            )

            keywordBoxes.append(KeywordBox(label: "ID", content: value, contentBox: valueBox, keyword: keyword, keywordBox: keywordBox))
        }

        if let match = originalText.wholeMatch(of: regexManager.pwRegex) {
            let keyword = String(match.1)
            let value = String(match.2).trimmingCharacters(in: .whitespaces)
            let valueBox = self.splitBoundingBox(originalBox: boundingBox, splitFactor: CGFloat(1 - Double(String(match.2).count) / Double(originalText.count)))
            let keywordBox = CGRect(
                x: boundingBox.minX,
                y: boundingBox.minY,
                width: boundingBox.width - valueBox.width,
                height: boundingBox.height
            )

            keywordBoxes.append(KeywordBox(label: "PW", content: value, contentBox: valueBox, keyword: keyword, keywordBox: keywordBox))
        }

        if !keywordBoxes.isEmpty {
            return keywordBoxes
        }


        /**
        let (keyword, cleanedText, index) = replaceDelimiterAfterKeyword(in: originalText, keywords: idKeywords + pwKeywords)

        // ID or PW 키워드가 있는 경우 처리
        if let keyword = keyword {
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
        }
         */

        // ID or PW 키워드가 없는 경우 처리

        let cleanedText = originalText.trimmingCharacters(in: .whitespaces)

        return [KeywordBox(label: "", content: cleanedText, contentBox: boundingBox, keyword: nil, keywordBox: nil)]
    }

//    private func replaceDelimiterAfterKeyword(in text: String, keywords: Array<String>) -> (String?, String, Int?) {
//        // 각 키워드를 순회하며 해당 키워드가 있는 위치를 찾습니다.
//        for (index, keyword) in keywords.enumerated() {
//            if let range = text.range(of: "\\b\(keyword)\\b", options: .regularExpression) {
//                // 키워드 뒤의 텍스트 추출
//                var modifiedSuffix = text[range.upperBound...].trimmingCharacters(in: .whitespaces)
//
//                // 첫 번째 문자가 특수 문자일 경우, 알파벳이나 숫자가 나올 때까지 공백으로 대체
//                while let firstChar = modifiedSuffix.first, ":-._\\/|)]}".contains(firstChar) {
//                    modifiedSuffix.replaceSubrange(modifiedSuffix.startIndex...modifiedSuffix.startIndex, with: " ")
//
//                    modifiedSuffix = modifiedSuffix.trimmingCharacters(in: .whitespaces)
//                }
//                return (keyword, modifiedSuffix.trimmingCharacters(in: .whitespaces), index)
//
//            }
//        }
//
//        // 키워드가 발견되지 않은 경우
//        return (nil, text, nil)
//    }

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


/**
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

        async let ssidTaskValue: (rect: CGRect, text: String)? = findSSIDBoundingBoxTask(extractedBoxes: extractedBoxes)

        async let passwordTaskValue: (rect: CGRect, text: String)? = findPasswordBoundingBox(extractedBoxes: extractedBoxes)


        let ssidResult = await ssidTaskValue
        let passwordResult = await passwordTaskValue

        return OCRResultVO(ssidBoundingBox: ssidResult?.rect, passwordBoundingBox: passwordResult?.rect, ssid: ssidResult?.text, password: passwordResult?.text)
    }

    private func findSSIDBoundingBoxTask(extractedBoxes: ExtractedBoxes) async -> (rect: CGRect, text: String)? {
        if let ssid = self.ssidBox(with: extractedBoxes) {
            let delimiters = CharacterSet(charactersIn: "/,")
            let separatedSsidValue = ssid.1.components(separatedBy: delimiters).first ?? ssid.1
            let ssidText: String = separatedSsidValue.replacingOccurrences(of: " ", with: "")
            return (ssid.0, ssidText)
        } else {
            return nil
        }
    }

    private func findPasswordBoundingBox(extractedBoxes: ExtractedBoxes) async -> (rect: CGRect, text: String)? {
        if let password = self.passwordBox(with: extractedBoxes) {
            let delimiters = CharacterSet(charactersIn: "/,")
            let separatedSsidValue = password.1.components(separatedBy: delimiters).first ?? password.1
            let passwordText: String = separatedSsidValue.replacingOccurrences(of: " ", with: "")
            return (password.0, passwordText)
        } else {
            return nil
        }
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
 */
