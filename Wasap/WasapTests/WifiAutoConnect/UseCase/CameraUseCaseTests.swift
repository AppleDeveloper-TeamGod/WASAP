//
//  CameraUseCaseTests.swift
//  Wasap
//
//  Created by chongin on 10/7/24.
//
/*
import RxSwift
import AVFoundation
@testable import Wasap
import Testing
import RxSwift
import RxBlocking
import UIKit

class MockCameraRepository: NSObject, CameraRepository {
    
    var captureSession: AVCaptureSession?
    private var stillImageOutput: AVCapturePhotoOutput?

    // 카메라 프리뷰 설정
    func configureCamera() -> Single<AVCaptureSession> {
        return Single.create { [weak self] single in
            guard let self = self else { return Disposables.create() }
            let mockSession = AVCaptureSession()
            mockSession.sessionPreset = .photo
            self.captureSession = mockSession
            single(.success(mockSession))

            return Disposables.create {
                mockSession.stopRunning()
            }
        }
    }

    // 사진 촬영
    func capturePhoto() -> Single<Data> {
        return Single.create { single in
            if let mockImage = UIImage(systemName: "star")?.pngData() {
                single(.success(mockImage))
            }

            return Disposables.create()
        }
    }

    func startRunning() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession?.startRunning()
        }
    }

    func stopRunning() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession?.stopRunning()
        }
    }

    func getPreviewLayer() -> Single<AVCaptureVideoPreviewLayer> {
        return Single.create {
            $0(.failure(CameraErrors.previewLayerError))
            return Disposables.create()
        }
    }
}

/// CameraUseCaseTests
struct CameraUseCaseTests {
    var mockRepository: MockCameraRepository!
    var cameraUseCase: DefaultCameraUseCase!

    init() async throws {
        mockRepository = MockCameraRepository()
        cameraUseCase = DefaultCameraUseCase(repository: mockRepository)
    }

    /// 카메라 프리뷰 시작 테스트
    @Test
    func testStartCameraPreviewSuccess() throws {

        // UseCase 실행
        let result: Void? = try? cameraUseCase.configureCamera().toBlocking().first()

        // 결과 검증
        try #require(result != nil)
    }

    /// 사진 촬영 성공 테스트
    @Test
    func testTakePhotoSuccess() throws {
        _ = try cameraUseCase.configureCamera().toBlocking().first()

        try testStartCameraPreviewSuccess()

        cameraUseCase.startRunning()

        // UseCase 실행
        let result = try? cameraUseCase.takePhoto().toBlocking().first()

        // 결과 검증
        try #require(result != nil)
    }
}
*/
