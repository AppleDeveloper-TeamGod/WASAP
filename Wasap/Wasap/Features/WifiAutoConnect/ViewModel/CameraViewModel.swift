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
    private let wifiConnectUseCase: WiFiConnectUseCase
    private let wifiShareUseCase: WiFiShareUseCase

    // MARK: - Input
    public var zoomSliderValue = PublishRelay<CGFloat>()
    public var zoomPinchGestureDidChange = PublishRelay<UIPinchGestureRecognizer>()
    public var zoomControlButtonDidTap = PublishRelay<Void>()
    public var shutterButtonDidTap = PublishRelay<Void>()
    public var tipButtonDidTap = PublishRelay<Void>()

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
    private var currentZoomValue = BehaviorRelay<CGFloat>(value: 2.0)
    private var captureRect = BehaviorRelay<CGRect>(value: CGRect(x: 32, y: 92, width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.78))
    private let isModalPresented = BehaviorRelay<Bool>(value: false)
    private let isNotWifiQR = PublishRelay<Void>()
    private let latestSSID = BehaviorRelay<String>(value: "")
    private let latestPassword = BehaviorRelay<String>(value: "")

    // MARK: - Init & Binding
    public init(cameraUseCase: CameraUseCase, imageAnalysisUseCase: ImageAnalysisUseCase, wifiConnectUseCase: WiFiConnectUseCase, wifiShareUseCase: WiFiShareUseCase, coordinatorController: CameraCoordinatorController) {
        self.cameraUseCase = cameraUseCase
        self.imageAnalysisUseCase = imageAnalysisUseCase
        self.wifiConnectUseCase = wifiConnectUseCase
        self.wifiShareUseCase = wifiShareUseCase
        self.coordinatorController = coordinatorController

        let previewLayerRelay = PublishRelay<AVCaptureVideoPreviewLayer>()
        self.previewLayer = previewLayerRelay.asDriver(onErrorDriveWith: .empty())

        let qrCodeCornersRelay = BehaviorRelay<[CGPoint]?>(value: nil)
        let qrCodeNoResponseTrigger = qrCodeCornersRelay.debounce(.milliseconds(1500), scheduler: MainScheduler.asyncInstance).map({ _ -> [CGPoint]? in nil })
        self.qrCodePoints = Observable.merge(qrCodeCornersRelay.asObservable(), qrCodeNoResponseTrigger).asDriver(onErrorJustReturn: nil)


        let ssidRelay = BehaviorRelay<CGRect?>(value: nil)
        let ssidNoResponseTrigger = ssidRelay.debounce(.milliseconds(1500), scheduler: MainScheduler.asyncInstance).map({ _ -> CGRect? in nil })
        self.ssidRect = Observable.merge(ssidRelay.asObservable(), ssidNoResponseTrigger).asDriver(onErrorJustReturn: nil)

        let passwordRelay = BehaviorRelay<CGRect?>(value: nil)
        let passwordNoResponseTrigger = passwordRelay.debounce(.milliseconds(1500), scheduler: MainScheduler.asyncInstance).map({ _ -> CGRect? in nil })
        self.passwordRect = Observable.merge(passwordRelay.asObservable(), passwordNoResponseTrigger).asDriver(onErrorJustReturn: nil)

        let zoomValueRelay = PublishRelay<CGFloat>()
        self.zoomValue = zoomValueRelay.asDriver(onErrorDriveWith: .empty())

        let isPinchingRelay = BehaviorRelay<Bool>(value: false)
        self.isPinching = isPinchingRelay.distinctUntilChanged().asDriver(onErrorDriveWith: .empty())

        let minMaxZoomFactorRelay = PublishRelay<(min: CGFloat, max: CGFloat)>()
        self.minMaxZoomFactor = minMaxZoomFactorRelay.asDriver(onErrorDriveWith: .empty())

        /// 공유 수신
        let isBrowsing = BehaviorRelay<Bool>(value: false)
        let receivedWiFiInfo = PublishRelay<(ssid: String, password: String)>()

        super.init()

        let isCameraConfigured = PublishRelay<Void>()

        NotificationCenter.default.addObserver(self, selector: #selector(handleReceivingViewDidPresent), name: .viewDidPresent, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleReceivingViewDidDismiss), name: .viewDidDismiss, object: nil)

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

        viewDidLoad
            .delay(.seconds(2), scheduler: MainScheduler.asyncInstance)
            .subscribe { _ in
                Toaster.shared.toast("안내문을 중앙에 두고 촬영하세요", delay: 3.0, top: 24)
            }
            .disposed(by: disposeBag)

        viewDidAppear
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
            .delay(.seconds(2), scheduler: MainScheduler.asyncInstance)
            .subscribe { _ in
                SplashController.shared.finishSplash()
            }
            .disposed(by: disposeBag)

        viewDidDisappear
            .withUnretained(self)
            .subscribe { owner, _ in
                owner.cameraUseCase.stopRunning()
                owner.wifiShareUseCase.stopBrowsing()
                isBrowsing.accept(false)
            }
            .disposed(by: disposeBag)

        zoomSliderValue
            .distinctUntilChanged {
                Int($0 * 10)
            }
            .bind(to: currentZoomValue)
            .disposed(by: disposeBag)

        zoomPinchGestureDidChange
            .filter { $0.state == .began || $0.state == .changed }
            .withLatestFrom(currentZoomValue, resultSelector: {
                let pinchScale = $0.scale
                if pinchScale <= 1.0 {
                    return (1.0 - exp(1.0 - pinchScale)) * 3 + $1
                } else {
                    return (pinchScale - 1.0 + $1) * 1.5
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
                    return (pinchScale - 1.0 + $1) * 1.5
                }
            })
            .map { [weak self] value in
                self?.adjustedZoomValue(zoomValue: value) ?? 1.0
            }
            .subscribe { [weak self] newZoomValue in
                isPinchingRelay.accept(false)
                self?.currentZoomValue.accept(newZoomValue)
            }
            .disposed(by: disposeBag)

        isCameraConfigured
            .withUnretained(self)
            .observe(on: MainScheduler.asyncInstance)
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
            .withLatestFrom(isModalPresented) { ($0, $1) }
            .filter { _, isPresented in !isPresented }
            .compactMap { image, _ in image }
            .withUnretained(self)
            .flatMap { owner, image -> Single<OCRResultVO> in
                owner.imageAnalysisUseCase.performOCR(on: image)
            }
            .withUnretained(self)
            .subscribe { owner, ocrResult in
                guard let videoPreviewLayer: AVCaptureVideoPreviewLayer = owner.cameraUseCase.getCapturePreviewLayer() else { return }

                if let ssid = ocrResult.ssid, !ssid.isEmpty {
                    owner.latestSSID.accept(ssid)
                }

                if let password = ocrResult.password, !password.isEmpty {
                    owner.latestPassword.accept(password)
                }

                let convertedSSIDRect = ocrResult.ssidBoundingBox.map { box in
                    let rotatedX = box.minY
                    let rotatedY = 1.0 - box.maxX
                    let rotatedWidth = box.height
                    let rotatedHeight = box.width
                    let rect = CGRect(x: rotatedX, y: rotatedY, width: rotatedWidth, height: rotatedHeight)
                    return videoPreviewLayer.layerRectConverted(fromMetadataOutputRect: rect)
                }
                let convertedPasswordRect = ocrResult.passwordBoundingBox.map { box in
                    let rotatedX = box.minY
                    let rotatedY = 1.0 - box.maxX
                    let rotatedWidth = box.height
                    let rotatedHeight = box.width
                    let rect = CGRect(x: rotatedX, y: rotatedY, width: rotatedWidth, height: rotatedHeight)
                    return videoPreviewLayer.layerRectConverted(fromMetadataOutputRect: rect)
                }

                ssidRelay.accept(convertedSSIDRect)
                passwordRelay.accept(convertedPasswordRect)

                var unionedRect: CGRect = CGRect(x: 32, y: 92, width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.78)
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
            .subscribe { owner, _ in
                let (minimum, maximum) = owner.cameraUseCase.getMinMaxZoomFactor()
                minMaxZoomFactorRelay.accept((min: minimum ?? 1.0, max: maximum ?? 1.0))
            }
            .disposed(by: disposeBag)

        let getQRDataStream = isCameraConfigured
            .withUnretained(self)
            .flatMapLatest { owner, _ -> Observable<(qrString: String, corners: [CGPoint])?> in
                owner.cameraUseCase.getQRDataStream()
            }
            .map { [weak self] qrDataWithCorners -> (qrString: String, corners: [CGPoint])? in
                guard let qrDataWithCorners else {
                    return nil
                }
                guard qrDataWithCorners.qrString.lowercased().hasPrefix("wifi:") else {
                    self?.isNotWifiQR.accept(())
                    return nil
                }
                return qrDataWithCorners
            }
            .share()

        getQRDataStream
            .withUnretained(self)
            .subscribe { owner, qrData in
                qrCodeCornersRelay.accept(qrData?.corners ?? nil)
            }
            .disposed(by: disposeBag)

        getQRDataStream
            .withLatestFrom(isModalPresented) { ($0, $1) }
            .filter { _, isPresented in !isPresented }
            .compactMap { qrDataWithCorners, _ in qrDataWithCorners }
            .map(\.qrString)
            .distinctUntilChanged()
            .debounce(.milliseconds(1500), scheduler: MainScheduler.asyncInstance)
            .withUnretained(self)
            .compactMap { owner, qrString in
                owner.imageAnalysisUseCase.parseWiFiInfo(from: qrString)
            }
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe { owner, wifiInfo in
                Log.print("qr 발견!! : \(wifiInfo)")
                owner.coordinatorController?.performTransition(to: .connectWithQR(ssid: wifiInfo.ssid ?? "", password: wifiInfo.password ?? ""))
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
            .throttle(.seconds(3), latest: false, scheduler: MainScheduler.asyncInstance)
            .withLatestFrom(captureRect)
            .withUnretained(self)
            .flatMapLatest { owner, rect in
                owner.cameraUseCase.takePhoto(with: rect)
            }
            .withLatestFrom(latestSSID) { ($0, $1) }
            .withLatestFrom(latestPassword) { (image: $0.0, ssid: $0.1, password: $1) }
            .withUnretained(self)
            .subscribe { owner, info in
                owner.coordinatorController?.performTransition(to: .connecting(imageData: info.image, ssid: info.ssid, password: info.password))
            }
            .disposed(by: disposeBag)

        /// 공유 수신
        isCameraConfigured
            .withUnretained(self)
            .flatMapLatest { owner, _ in
                wifiShareUseCase.startBrowsing()
            }
            .subscribe {
                Log.debug("start Browsing")
                isBrowsing.accept(true)
            } onError: { error in
                Log.error("\(error.localizedDescription)")
            }
            .disposed(by: disposeBag)

        isBrowsing
            .filter { $0 }
            .withUnretained(self)
            .flatMapLatest { owner, _ -> Observable<(ssid: String, password: String)> in
                owner.wifiShareUseCase.getReceivedWiFiInfo()
            }
            .filter { [weak self] wifiInfo in
                self?.wifiConnectUseCase.getConnectedSSID() != wifiInfo.ssid
            }
            .subscribe {
                receivedWiFiInfo.accept($0)
            }
            .disposed(by: disposeBag)

        Observable.combineLatest(receivedWiFiInfo, isModalPresented)
            .filter { !$1 }
            .map(\.0)
            .distinctUntilChanged(\.ssid)
            .withUnretained(self)
            .subscribe { owner, wifiInfo in
                owner.coordinatorController?.performTransition(to: .receiving(ssid: wifiInfo.ssid, password: wifiInfo.password))

            }
            .disposed(by: disposeBag)

        /// TipButton
        tipButtonDidTap
            .withUnretained(self)
            .subscribe { owner, _ in
                owner.coordinatorController?.performTransition(to: .tip)
            }
            .disposed(by: disposeBag)

        /// Wifi QR이 아닐 때
        isNotWifiQR
            .throttle(.seconds(5), latest: false, scheduler: MainScheduler.asyncInstance)
            .subscribe { _ in
                Toaster.shared.importantToast("Wifi QR이 아닙니다")
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

    @objc private func handleReceivingViewDidPresent() {
        Log.print("Notification received: viewDidPresent")
        isModalPresented.accept(true)
    }

    @objc private func handleReceivingViewDidDismiss() {
        Log.print("Notification received: viewDidDismiss")
        isModalPresented.accept(false)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
