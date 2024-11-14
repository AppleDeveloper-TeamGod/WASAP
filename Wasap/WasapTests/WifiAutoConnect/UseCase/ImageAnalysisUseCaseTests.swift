//
//  ImageAnalysisUseCaseTests.swift
//  WasapTests
//
//  Created by Chang Jonghyeon on 10/9/24.
//

import RxSwift
import RxBlocking
import Testing
import UIKit
@testable import Wasap
import Vision

enum OCRTestCases: CaseIterable {
    case success1
    case success2
    case success3
    case success4
    case success5

    var inputImageName: String {
        switch self {
        case .success1: "previewTestImage1"
        case .success2: "previewTestImage2"
        case .success3: "previewTestImage3"
        case .success4: "previewTestImage4"
        case .success5: "previewTestImage5"
        }
    }

    var expectedAnswer: (ssid: String, password: String) {
        switch self {
        case .success1:
            return ("barbet_2F", "barbet1234")
        case .success2:
            return ("Tarrtarr", "12345678")
        case .success3:
            return ("SwiftFun", "WeAreDevs")
        case .success4:
            return ("KT_GiGA_5G_Wave2_CAC7", "ecff9be894")
        case .success5:
            return ("hands144", "hands144")
        }
    }
}

class ImageAnalysisUseCaseTests {
    var repository: ImageAnalysisRepository!
    var useCase: DefaultImageAnalysisUseCase
    let bundle: Bundle
    
    init() {
//        repository = DefaultImageAnalysisRepository()
        repository = QuickImageAnalysisRepository()
        useCase = DefaultImageAnalysisUseCase(imageAnalysisRepository: repository)
        bundle = Bundle(for: type(of: self))
    }
    
    // OCR 성공 테스트
    @Test("OCR Tests", arguments: OCRTestCases.allCases)
    func testPerformOCRSuccess(_ testCase: OCRTestCases) throws {
        guard let image = UIImage(named: testCase.inputImageName, in: bundle, compatibleWith: nil) else {
            Issue.record("이미지 불러올 수 없음")
            return
        }

        // UseCase 실행
        let result: OCRResultVO? = try useCase.performOCR(on: image).toBlocking().first()

        // 결과 검증
        try #require(result != nil)
        try #require(result!.ssid != nil)
        try #require(result!.password != nil)

        let answer = testCase.expectedAnswer
        #expect(result!.ssid == answer.ssid)
        #expect(result!.password == answer.password)
    }

    @Test("Vision Framework Tests", arguments: OCRTestCases.allCases)
    func testPerformVisionFrameworkSuccess(_ testCase: OCRTestCases) throws {
        guard let imageData = UIImage(named: testCase.inputImageName, in: bundle, compatibleWith: nil)?.jpegData(compressionQuality: 1.0) else {
            Issue.record("이미지 불러올 수 없음")
            return
        }


        guard let cgImage = self.convertDataToCGImage(imageData) else {
            Issue.record("CG Image 생성 실패")
            return
        }

        let orientation = self.extractOrientation(from: imageData)

        let englishRequest = self.createTextRequest(for: "en")
        let koreanRequest = self.createTextRequest(for: "ko")

        let requestHandler = VNImageRequestHandler(cgImage: cgImage,
                                                   orientation: orientation,
                                                   options: [:])

        try? requestHandler.perform([englishRequest, koreanRequest])

    }

    private func createTextRequest(for language: String) -> VNRecognizeTextRequest {
        let request = VNRecognizeTextRequest()
        request.recognitionLanguages = [language]
        request.usesLanguageCorrection = true
        request.recognitionLevel = .accurate
        request.customWords = ["ID", "PW"]
        return request
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

    // OCR 실패 테스트
//    @Test
//    func testPerformOCRError() throws {
//        guard let image = UIImage(named: "OCRTestImage2", in: bundle, compatibleWith: nil) else {
//            Issue.record("이미지 불러올 수 없음")
//            return
//        }
//
//        let result: OCRResultVO? = try useCase.performOCR(on: image).toBlocking().first()
//
//        try #require(!(result!.ssidBoundingBox!).isEmpty)
//        try #require(!(result!.passwordBoundingBox!).isEmpty)
//        #expect(result!.ssid == "")
//        #expect(result!.password == "")
//    }
}

