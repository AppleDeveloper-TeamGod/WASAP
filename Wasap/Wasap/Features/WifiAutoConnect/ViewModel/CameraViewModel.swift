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
    public var zoomSliderValue = PublishRelay<CGFloat>()
    public var zoomPinchGestureDidChange = PublishRelay<UIPinchGestureRecognizer>()
    public var zoomControlButtonDidTap = PublishRelay<Void>()
    public var shutterButtonDidTap = PublishRelay<Void>()

    // MARK: - Output
    public var previewLayer: Driver<AVCaptureVideoPreviewLayer>
    public var qrCodePoints: Driver<[CGPoint]?>
    public var ssidRect: Driver<CGRect?>
    public var passwordRect: Driver<CGRect?>
    public var zoomValue: Driver<CGFloat>
    public var isPinching: Driver<Bool>
    public var minMaxZoomFactor: Driver<(min: CGFloat, max: CGFloat)>

    // MARK: - Properties
    private var isCameraRunning = BehaviorRelay<Bool>(value: false)
    private var currentZoomValue = BehaviorRelay<CGFloat>(value: 1.0)
    private var captureRect = BehaviorRelay<CGRect?>(value: nil)

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

        let zoomValueRelay = PublishRelay<CGFloat>()
        self.zoomValue = zoomValueRelay.asDriver(onErrorDriveWith: .empty())

        let isPinchingRelay = BehaviorRelay<Bool>(value: false)
        self.isPinching = isPinchingRelay.distinctUntilChanged().asDriver(onErrorDriveWith: .empty())

        let minMaxZoomFactorRelay = PublishRelay<(min: CGFloat, max: CGFloat)>()
        self.minMaxZoomFactor = minMaxZoomFactorRelay.asDriver(onErrorDriveWith: .empty())

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

        zoomSliderValue
            .bind(to: currentZoomValue)
            .disposed(by: disposeBag)

        zoomPinchGestureDidChange
            .filter { $0.state == .began || $0.state == .changed }
            .withLatestFrom(currentZoomValue, resultSelector: {
                let pinchScale = $0.scale
                if pinchScale <= 1.0 {
                    return (1.0 - exp(1.0 - pinchScale)) * 3 + $1
                } else {
                    return pinchScale - 1.0 + $1
                }
            })
            .distinctUntilChanged {
                Int($0 * 10)
            }
            .map { [weak self] value in
                self?.adjustedZoomValue(zoomValue: value) ?? 1.0
            }
            .subscribe { [weak self] appliedZoomValue in
                isPinchingRelay.accept(true)
                zoomValueRelay.accept(appliedZoomValue)
                self?.cameraUseCase.zoom(appliedZoomValue)
            }
            .disposed(by: disposeBag)

        zoomPinchGestureDidChange
            .filter { $0.state == .ended }
            .withLatestFrom(currentZoomValue, resultSelector: {
                let pinchScale = $0.scale
                if pinchScale <= 1.0 {
                    return (1.0 - exp(1.0 - pinchScale)) * 3 + $1
                } else {
                    return pinchScale - 1.0 + $1
                }
            })
            .map { [weak self] value in
                self?.adjustedZoomValue(zoomValue: value) ?? 1.0
            }
            .subscribe { [weak self] newZoomValue in
                isPinchingRelay.accept(false)
                Toaster.shared.toast("value : \(newZoomValue)")
                self?.currentZoomValue.accept(newZoomValue)
            }
            .disposed(by: disposeBag)

        isCameraConfigured
            .observe(on: MainScheduler.instance)
            .subscribe { _ in
                Toaster.shared.toast("안내문을 중앙에 두고 촬영하세요")
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
            .flatMapLatest { owner, image -> Single<OCRResultVO> in
                owner.imageAnalysisUseCase.performOCR(on: image)
            }
            .withUnretained(self)
            .subscribe { owner, ocrResult in
                guard let videoPreviewLayer: AVCaptureVideoPreviewLayer = owner.cameraUseCase.getCapturePreviewLayer() else { return }

                let convertedSSIDRect = ocrResult.ssidBoundingBox.map { box in
                    videoPreviewLayer.layerRectConverted(fromMetadataOutputRect: box)
                }
                let convertedPasswordRect = ocrResult.passwordBoundingBox.map { box in
                    videoPreviewLayer.layerRectConverted(fromMetadataOutputRect: box)
                }

                ssidRelay.accept(convertedSSIDRect)
                passwordRelay.accept(convertedPasswordRect)

                var unionedRect: CGRect? = nil
                if let ssidRect = convertedSSIDRect, let passwordRect = convertedPasswordRect {
                    unionedRect = ssidRect.union(passwordRect)
                } else if let ssidRect = convertedSSIDRect {
                    unionedRect = ssidRect
                } else if let passwordRect = convertedPasswordRect {
                    unionedRect = passwordRect
                }
                
                owner.captureRect.accept(unionedRect)
            }
            .disposed(by: disposeBag)

        isCameraConfigured
            .withUnretained(self)
            .flatMapLatest { owner, _ -> Observable<(qrString: String, corners: [CGPoint])?> in
                owner.cameraUseCase.getQRDataStream()
            }
            .withUnretained(self)
            .subscribe { owner, qrData in
                qrCodeCornersRelay.accept(qrData?.corners ?? nil)
            }
            .disposed(by: disposeBag)

        isCameraConfigured
            .withUnretained(self)
            .subscribe { owner, _ in
                let (minimum, maximum) = owner.cameraUseCase.getMinMaxZoomFactor()
                minMaxZoomFactorRelay.accept((min: minimum ?? 1.0, max: maximum ?? 1.0))
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

        Observable.combineLatest(isCameraRunning, currentZoomValue)
            .filter(\.0)
            .map(\.1)
            .distinctUntilChanged {
                Int($0 * 10)
            }
            .subscribe { [weak self] value in
                zoomValueRelay.accept(value)
                self?.cameraUseCase.zoom(value)
            }
            .disposed(by: disposeBag)

        shutterButtonDidTap
            .withLatestFrom(captureRect)
            .withUnretained(self)
            .flatMapLatest { owner, rect in
                owner.cameraUseCase.takePhoto(with: rect)
            }
            .withUnretained(self)
            .subscribe { owner, image in
                owner.coordinatorController?.performTransition(to: .analysis(imageData: image))
            }
            .disposed(by: disposeBag)
    }

    private func adjustedZoomValue(zoomValue: CGFloat) -> CGFloat {
        let (minimum, maximum) = self.cameraUseCase.getMinMaxZoomFactor()
        guard let minimum, let maximum else { return 1.0 }
        if zoomValue < minimum {
            return minimum
        } else if zoomValue > maximum {
            return maximum
        } else {
            return zoomValue
        }
    }
}
