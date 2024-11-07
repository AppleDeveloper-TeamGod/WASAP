//
//  CameraViewModel.swift
//  Wasap
//
//  Created by chongin on 10/10/24.
//

import RxSwift
import RxCocoa
import AVFoundation
import UIKit

public class CameraViewModel: BaseViewModel {
    // MARK: - Coordinator
    private weak var coordinatorController: CameraCoordinatorController?

    // MARK: - UseCase
    private let cameraUseCase: CameraUseCase
    private let imageAnalysisUseCase: ImageAnalysisUseCase

    // MARK: - Input
    public var zoomValue = BehaviorRelay<CGFloat>(value: 1.0)
    public var zoomControlButtonDidTap = PublishRelay<Void>()
    public var shutterButtonDidTap = PublishRelay<Void>()

    // MARK: - Output
    public var previewLayer: Driver<AVCaptureVideoPreviewLayer>
    public var qrCodePoints: Driver<[CGPoint]?>
    public var ssidRect: Driver<CGRect?>
    public var passwordRect: Driver<CGRect?>
    /// 임시
    public var tempImage: Driver<UIImage>
    ///

    // MARK: - Properties
    private var isCameraRunning = BehaviorRelay<Bool>(value: false)

    // MARK: - Init & Binding
    public init(cameraUseCase: CameraUseCase, imageAnalysisUseCase: ImageAnalysisUseCase, coordinatorController: CameraCoordinatorController) {
        self.cameraUseCase = cameraUseCase
        self.imageAnalysisUseCase = imageAnalysisUseCase
        self.coordinatorController = coordinatorController

        let previewLayerRelay = PublishRelay<AVCaptureVideoPreviewLayer>()
        self.previewLayer = previewLayerRelay.asDriver(onErrorDriveWith: .empty())

        let qrCodeCornersRelay = BehaviorRelay<[CGPoint]?>(value: nil)
        let qrCodeNoResponseTrigger = qrCodeCornersRelay.debounce(.seconds(2), scheduler: MainScheduler.instance).map({ _ -> [CGPoint]? in nil })
        self.qrCodePoints = Observable.merge(qrCodeCornersRelay.asObservable(), qrCodeNoResponseTrigger).asDriver(onErrorJustReturn: nil)


        let ssidRelay = BehaviorRelay<CGRect?>(value: nil)
        let ssidNoResponseTrigger = ssidRelay.debounce(.seconds(2), scheduler: MainScheduler.instance).map({ _ -> CGRect? in nil })
        self.ssidRect = Observable.merge(ssidRelay.asObservable(), ssidNoResponseTrigger).asDriver(onErrorJustReturn: nil)

        let passwordRelay = BehaviorRelay<CGRect?>(value: nil)
        let passwordNoResponseTrigger = passwordRelay.debounce(.seconds(2), scheduler: MainScheduler.instance).map({ _ -> CGRect? in nil })
        self.passwordRect = Observable.merge(passwordRelay.asObservable(), passwordNoResponseTrigger).asDriver(onErrorJustReturn: nil)

        let tempImageRelay = PublishRelay<UIImage>()
        self.tempImage = tempImageRelay.asDriver(onErrorDriveWith: .empty())

        super.init()

        let isCameraConfigured = PublishRelay<Void>()

        viewDidLoad
            .withUnretained(self)
            .flatMapLatest { owner, _ in
                cameraUseCase.configureCamera()
            }
            .subscribe {
                Log.debug("Camera Configure Completed")
                isCameraConfigured.accept($0)
            } onError: { error in
                Log.error("\(error.localizedDescription)")
            }
            .disposed(by: disposeBag)

        viewDidAppear
            .bind(to: isCameraConfigured)
            .disposed(by: disposeBag)

        viewDidDisappear
            .withUnretained(self)
            .subscribe { owner, _ in
                owner.cameraUseCase.stopRunning()
            }
            .disposed(by: disposeBag)

        /// 임시
        ///
        isCameraConfigured
            .withUnretained(self)
            .flatMapLatest { owner, _ in
                owner.cameraUseCase.getPreviewImageDataStream()
            }
            .subscribe { image in
                tempImageRelay.accept(image)
            }
            .disposed(by: disposeBag)
        ///

        isCameraConfigured
            .withUnretained(self)
            .flatMapLatest { owner, _  in
                owner.cameraUseCase.startRunning()
            }
            .withUnretained(self)
            .subscribe { owner, _ in
                Log.debug("Camera start running")
                owner.isCameraRunning.accept(true)
            } onError: { error in
                Log.error(error.localizedDescription)
            }
            .disposed(by: disposeBag)

        isCameraConfigured
            .withUnretained(self)
            .flatMapLatest { owner, _ in
                owner.cameraUseCase.getPreviewImageDataStream()
            }
            .withUnretained(self)
            .flatMapLatest { owner, image -> Single<OCRResultVO> in
                owner.imageAnalysisUseCase.performOCR(on: image)
            }
            .withUnretained(self)
            .subscribe { owner, ocrResult in
                Log.debug("boxes(\(ocrResult.boundingBoxes.count): \(ocrResult.boundingBoxes), ssid : \(ocrResult.ssid), password : \(ocrResult.password)")

                guard let videoPreviewLayer = owner.cameraUseCase.getCapturePreviewLayer() else { return }

                let convertedSSIDRect = ocrResult.ssidBoundingBox.map { box in
                    videoPreviewLayer.layerRectConverted(fromMetadataOutputRect: box)
                }
                let convertedPasswordRect = ocrResult.passwordBoundingBox.map { box in
                    videoPreviewLayer.layerRectConverted(fromMetadataOutputRect: box)
                }

                ssidRelay.accept(convertedSSIDRect)
                passwordRelay.accept(convertedPasswordRect)
            }
            .disposed(by: disposeBag)

        isCameraConfigured
            .withUnretained(self)
            .flatMapLatest { owner, _ -> Observable<(qrString: String, corners: [CGPoint])?> in
                owner.cameraUseCase.getQRDataStream()
            }
            .withUnretained(self)
            .subscribe { owner, qrData in
                Log.debug("QR Code String : \(qrData?.qrString)")
                Log.debug("QR Code Corners : \(qrData?.corners)")
                qrCodeCornersRelay.accept(qrData?.corners ?? nil)
            }
            .disposed(by: disposeBag)

        isCameraRunning
            .filter { $0 }
            .withUnretained(self)
            .flatMapLatest { owner, _ -> Single<AVCaptureVideoPreviewLayer> in
                owner.cameraUseCase.getCapturePreviewLayer()
            }
            .subscribe {
                previewLayerRelay.accept($0)
            } onError: { error in
                Log.error(error.localizedDescription)
            }
            .disposed(by: disposeBag)

        Observable.combineLatest(isCameraRunning, zoomValue)
            .filter(\.0)
            .subscribe { [weak self] _, value in
                self?.cameraUseCase.zoom(value)
            }
            .disposed(by: disposeBag)

        shutterButtonDidTap
            .withUnretained(self)
            .flatMapLatest { owner, _ in
                owner.cameraUseCase.takePhoto()
            }
            .withUnretained(self)
            .subscribe { owner, image in
                owner.coordinatorController?.performTransition(to: .analysis(imageData: image))
            }
            .disposed(by: disposeBag)
    }
}
