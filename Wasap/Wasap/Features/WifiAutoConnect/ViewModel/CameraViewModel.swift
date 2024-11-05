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
    public var shutterButtonDidTapWithMask = PublishRelay<CGRect>()

    // MARK: - Output
    public var previewLayer: Driver<AVCaptureVideoPreviewLayer>
    public var isZoomControlButtonHidden: Driver<Bool>
    public var qrCodeCorners: Driver<[CGPoint]?>

    // MARK: - Properties
    private var isCameraRunning = BehaviorRelay<Bool>(value: false)

    // MARK: - Init & Binding
    public init(cameraUseCase: CameraUseCase, imageAnalysisUseCase: ImageAnalysisUseCase, coordinatorController: CameraCoordinatorController) {
        self.cameraUseCase = cameraUseCase
        self.imageAnalysisUseCase = imageAnalysisUseCase
        self.coordinatorController = coordinatorController

        let previewLayerRelay = PublishRelay<AVCaptureVideoPreviewLayer>()
        self.previewLayer = previewLayerRelay.asDriver(onErrorDriveWith: .empty())

        let isZoomControlButtonHiddenRelay = BehaviorRelay<Bool>(value: false)
        self.isZoomControlButtonHidden = isZoomControlButtonHiddenRelay.asDriver(onErrorDriveWith: .empty())

        let qrCodeCornersRelay = BehaviorRelay<[CGPoint]?>(value: nil)
        self.qrCodeCorners = qrCodeCornersRelay.asDriver(onErrorDriveWith: .empty())

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
            .flatMapLatest { owner, image in
                owner.imageAnalysisUseCase.performOCR(on: image)
            }
            .withUnretained(self)
            .subscribe { owner, ocrResult in
                let (image, ssid, password) = ocrResult
                Log.debug("image: \(image), ssid : \(ssid), password : \(password)")
            }
            .disposed(by: disposeBag)

        isCameraConfigured
            .withUnretained(self)
            .flatMapLatest { owner, _ in
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

        Observable.combineLatest(zoomValue, zoomControlButtonDidTap)
            .debounce(.seconds(3), scheduler: MainScheduler.instance)
            .map { _ in false }
            .bind(to: isZoomControlButtonHiddenRelay)
            .disposed(by: disposeBag)

        zoomControlButtonDidTap
            .map { _ in true }
            .bind(to: isZoomControlButtonHiddenRelay)
            .disposed(by: disposeBag)

        shutterButtonDidTapWithMask
            .withUnretained(self)
            .flatMapLatest { owner, rect -> Single<UIImage> in
                owner.cameraUseCase.takePhoto(cropRect: rect)
            }
            .withUnretained(self)
            .subscribe { owner, image in
                owner.coordinatorController?.performTransition(to: .analysis(imageData: image))
            }
            .disposed(by: disposeBag)
    }
}
