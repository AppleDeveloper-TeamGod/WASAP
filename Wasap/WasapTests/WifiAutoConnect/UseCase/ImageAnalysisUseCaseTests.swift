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

enum OCRTestCases: CaseIterable {
    case success1
    case success2
    case success3
    case success4

    var inputImageName: String {
        switch self {
        case .success1: "previewTestImage1"
        case .success2: "previewTestImage2"
        case .success3: "previewTestImage3"
        case .success4: "previewTestImage4"
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
        }
    }
}

class ImageAnalysisUseCaseTests {
    var repository: DefaultImageAnalysisRepository!
    var useCase: DefaultImageAnalysisUseCase
    let bundle: Bundle
    
    init() {
        repository = DefaultImageAnalysisRepository()
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
    
    // OCR 실패 테스트
    @Test
    func testPerformOCRError() throws {
        guard let image = UIImage(named: "OCRTestImage2", in: bundle, compatibleWith: nil) else {
            Issue.record("이미지 불러올 수 없음")
            return
        }

        let result: OCRResultVO? = try useCase.performOCR(on: image).toBlocking().first()

        try #require(!(result!.ssidBoundingBox!).isEmpty)
        try #require(!(result!.passwordBoundingBox!).isEmpty)
        #expect(result!.ssid == "")
        #expect(result!.password == "")
    }
}

