//
//  CameraRepository.swift
//  Wasap
//
//  Created by chongin on 10/7/24.
//

import RxSwift
import AVFoundation
import UIKit

public protocol CameraRepository {

    /// configureCamera : 카메라의 초기 설정을 담당. Input과 Output을 지정함.
    /// configure과 previewLayer 세팅이 끝나면 startRunning() 함수로 시작하세요.
    func configureCamera() -> Single<AVCaptureSession>

    /// getPreviewLayer : 프리뷰 레이어를 가져옵니다. 뷰에서 이 레이어를 활용하세요.
    func getPreviewLayer() -> Single<AVCaptureVideoPreviewLayer>
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer?

    /// startRunning() : 카메라 프리뷰를 시작합니다. 시작되면 이벤트를 넘깁니다.
    func startRunning() -> Single<Void>

    /// stopRunning() : 카메라 프리뷰를 중지합니다. 캡쳐 대기를 종료합니다.
    func stopRunning()

    /// capturePhoto() : 캡쳐를 수행합니다. 그 결과를 Single로 받습니다.
    func capturePhoto() -> Single<Data>

    /// getPreviewImageStream() : 프리뷰 레이어로 가져오는 UIImage 정보가 담깁니다.
    func getPreviewImageStream() -> Observable<UIImage>

    func getQRDataStream() -> Observable<(qrString: String, corners: [CGPoint])?>

    /// zoom() : 줌을 수행합니다.
    func zoom(_ factor: CGFloat)

    /// getMinimumZoomFactor() : minimum zoom fact를 구합니다
    func getMinZoomFactor() -> CGFloat?

    /// getMaximumZoomFactor() : maximum zoom fact를 구합니다
    func getMaxZoomFactor() -> CGFloat?
}

final public class DefaultCameraRepository: NSObject, CameraRepository {
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?

    private var photoOutput: AVCapturePhotoOutput?
    private var captureVideoOutput: AVCaptureVideoDataOutput?
    private var captureQROutput: AVCaptureMetadataOutput?

    private var photoCaptureCompletion: ((Result<Data, Error>) -> Void)?

    private var capturedVideoDataStream = PublishSubject<UIImage>()
    private var capturedQRDataStream = PublishSubject<(qrString: String, corners: [CGPoint])?>()

    public func requestAuthorization() -> Single<Void> {
        return Single.create { single in
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            if status == .authorized {
                Log.print("Auth Success!")
                single(.success(()))
            } else if status == .notDetermined {
                AVCaptureDevice.requestAccess(for: .video) { isAuthorized in
                    if isAuthorized {
                        Log.print("Auth Success!")
                        single(.success(()))
                    } else {
                        Log.error("Auth Failure!")
                        single(.failure(CameraErrors.notAuthorized))
                    }
                }
            } else {
                Log.error("Auth Failure!")
                single(.failure(CameraErrors.notAuthorized))
            }
            return Disposables.create()
        }
    }

    public func configureCamera() -> Single<AVCaptureSession> {
        let configureStream = Single<AVCaptureSession>.create { [weak self] single in
            let session = AVCaptureSession()
            session.beginConfiguration()

            session.sessionPreset = .photo

            guard let backCamera = AVCaptureDevice.default(for: .video) else {
                session.commitConfiguration()
                single(.failure(CameraErrors.cameraNotFound))
                return Disposables.create()
            }

            do {
                let input = try AVCaptureDeviceInput(device: backCamera)
                session.addInput(input)

                self?.photoOutput = AVCapturePhotoOutput()
                if session.canAddOutput((self?.photoOutput!)!) {
                    session.addOutput((self?.photoOutput!)!)
                }

                self?.captureVideoOutput = AVCaptureVideoDataOutput()
                self?.captureVideoOutput?.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
                if session.canAddOutput((self?.captureVideoOutput!)!) {
                    session.addOutput((self?.captureVideoOutput!)!)
                }

                self?.captureQROutput = AVCaptureMetadataOutput()
                if session.canAddOutput((self?.captureQROutput!)!) {
                    session.addOutput((self?.captureQROutput!)!)
                    self?.captureQROutput?.setMetadataObjectsDelegate(self, queue: DispatchQueue(label: "qrQueue"))
                    self?.captureQROutput?.metadataObjectTypes = [.qr]
                }

                self?.captureSession = session
                session.commitConfiguration()
                single(.success(session))
            } catch {
                session.commitConfiguration()
                single(.failure(CameraErrors.captureDeviceError))
            }

            return Disposables.create()
        }

        return requestAuthorization()
            .flatMap { _ in
                configureStream
            }
    }

    public func getPreviewLayer() -> Single<AVCaptureVideoPreviewLayer> {
        Single.create { [weak self] single in
            guard let captureSession = self?.captureSession else {
                Log.error("아이고.. configure camera를 먼저 해줘야 해요.")
                single(.failure(CameraErrors.previewLayerError))
                return Disposables.create()
            }

            if let preview = self?.previewLayer {
                single(.success(preview))
            } else {
                let newPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                newPreviewLayer.videoGravity = .resizeAspectFill
                self?.previewLayer = newPreviewLayer
                single(.success(newPreviewLayer))
            }
            
            return Disposables.create()
        }

    }

    public func getPreviewLayer() -> AVCaptureVideoPreviewLayer? {
        return previewLayer
    }

    public func capturePhoto() -> Single<Data> {
        return Single.create { [weak self] single in
            guard let self else {
                single(.failure(CameraErrors.unknown))
                return Disposables.create()
            }
            guard let stillImageOutput = self.photoOutput else {
                single(.failure(CameraErrors.imageOutputNotAvailable))
                return Disposables.create()
            }

            let settings = AVCapturePhotoSettings()
            self.photoCaptureCompletion = { result in
                switch result {
                case .success(let data):
                    single(.success(data))
                case .failure(let error):
                    single(.failure(error))
                }
            }
            stillImageOutput.capturePhoto(with: settings, delegate: self)

            return Disposables.create()
        }
    }

    public func getPreviewImageStream() -> Observable<UIImage> {
        self.capturedVideoDataStream.asObservable()
    }

    public func getQRDataStream() -> Observable<(qrString: String, corners: [CGPoint])?> {
        self.capturedQRDataStream.asObservable()
    }

    public func startRunning() -> Single<Void> {
        return Single.create { [weak self] single in
            guard let self = self else {
                single(.failure(CameraErrors.unknown))
                return Disposables.create()
            }

            let notificationCenter = NotificationCenter.default
            let startRunningObserver = notificationCenter.addObserver(forName: AVCaptureSession.didStartRunningNotification, object: self.captureSession, queue: .main) { _ in
                Log.print("Camera started running")
                single(.success(()))
            }

            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession?.startRunning()
            }
            DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 10) {
                single(.failure(CameraErrors.unknown))
            }

            return Disposables.create {
                notificationCenter.removeObserver(startRunningObserver)
            }
        }
    }

    public func stopRunning() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.stopRunning()
        }
    }

    public func zoom(_ factor: CGFloat) {

        guard let minAvailableZoomScale = self.getMinZoomFactor(),
              let maxAvailableZoomScale = self.getMaxZoomFactor(),
              let device = self.getCurrentInputDevice()
        else {
            return
        }

        do {
            try device.lockForConfiguration()
            if minAvailableZoomScale...maxAvailableZoomScale ~= factor {
//                device.videoZoomFactor = factor
                device.ramp(toVideoZoomFactor: factor, withRate: 5.0)
            }
        } catch {
            return
        }
        device.unlockForConfiguration()
    }

    public func getMinZoomFactor() -> CGFloat? {
        let device = getCurrentInputDevice()

        return device?.minAvailableVideoZoomFactor
    }

    public func getMaxZoomFactor() -> CGFloat? {
        let device = getCurrentInputDevice()

        guard let maximum = device?.maxAvailableVideoZoomFactor else { return nil }
        return min(maximum, 15.0)
    }

    private func getCurrentInputDevice() -> AVCaptureDevice? {
        return (captureSession?.inputs.first as? AVCaptureDeviceInput)?.device
    }

}

extension DefaultCameraRepository: AVCapturePhotoCaptureDelegate {

    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error {
            photoCaptureCompletion?(.failure(error))
        } else if let imageData = photo.fileDataRepresentation() {
            photoCaptureCompletion?(.success(imageData))
        } else {
            photoCaptureCompletion?(.failure(CameraErrors.photoProcessingError))
        }
    }
}

extension DefaultCameraRepository: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        // CVPixelBuffer를 CIImage로 변환
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        self.capturedVideoDataStream.onNext(UIImage(ciImage: ciImage))
    }
}

extension DefaultCameraRepository: AVCaptureMetadataOutputObjectsDelegate {
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        for metadataObject in metadataObjects {
            if let qrCodeObject = metadataObject as? AVMetadataMachineReadableCodeObject, let qrCodeString = qrCodeObject.stringValue {
                guard let videoPreviewLayer = self.previewLayer else { return }

                // QR 코드 corners 값을 화면 좌표에 맞는 CGPoint로 변환
                let convertedCorners = qrCodeObject.corners.map { corner in
                    videoPreviewLayer.layerPointConverted(fromCaptureDevicePoint: corner)
                }

                if convertedCorners.filter({ point in
                    point.x <= 0 || point.y <= 0 || point.x >= videoPreviewLayer.bounds.width || point.y >= videoPreviewLayer.bounds.height
                }).isEmpty {
                    self.capturedQRDataStream.onNext((qrCodeString, convertedCorners))
                }
            }
        }
    }
}
