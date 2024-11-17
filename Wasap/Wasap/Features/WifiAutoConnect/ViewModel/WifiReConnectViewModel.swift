//
//  WifiConnectViewModel.swift
//  Wasap
//
//  Created by 김상준 on 10/7/24.
//
import RxSwift
import RxCocoa
import UIKit
import VisionKit

public class WifiReConnectViewModel: BaseViewModel {
    private let imageAnalyzer = ImageAnalyzer()

    // MARK: - Coordinator
    private weak var coordinatorController: WifiReConnectCoordinatorController?

    // MARK: - Input
    public let reConnectButtonTapped = PublishRelay<Void>()
    public let cameraButtonTapped = PublishRelay<Void>()
    public let ssidFieldTouched = PublishRelay<Void>()
    public let pwFieldTouched = PublishRelay<Void>()
    public let keyboardWillShow = PublishRelay<Void>()
    public let keyboardWillHide = PublishRelay<Void>()

    public let ssidText = BehaviorRelay<String>(value: "")
    public let pwText = BehaviorRelay<String>(value: "")
    public let photoImage = BehaviorRelay<UIImage>(value: UIImage())

    // MARK: - Output
    public let ssidDriver: Driver<String>
    public let passwordDriver: Driver<String>
    public let updatedImageDriver: Driver<UIImage>

    public let btnColorChangeDriver: Driver<Bool>
    public let ssidTextFieldTouchedDriver: Driver<Bool>
    public let pwTextFieldTouchedDriver: Driver<Bool>
    public let keyboardVisible = PublishRelay<Bool>()
    public let liveTextAnalysis = BehaviorRelay<ImageAnalysis?>(value: nil)

    public init(wifiConnectUseCase: WiFiConnectUseCase,
                coordinatorController: WifiReConnectCoordinatorController,
                image: UIImage, ssid: String, password: String) {

        self.coordinatorController = coordinatorController

        let updatedImageRelay = BehaviorRelay<UIImage>(value: image)
        self.updatedImageDriver = updatedImageRelay.asDriver()

        let ssidRelay = BehaviorRelay<String>(value: ssid)
        self.ssidDriver = ssidRelay.asDriver()

        let passwordRelay = BehaviorRelay<String>(value: password)
        self.passwordDriver = passwordRelay.asDriver()

        let btnColorChangeRelay = BehaviorRelay<Bool>(value: false)
        self.btnColorChangeDriver = btnColorChangeRelay.asDriver()

        let ssidTextFieldColorChangeRelay = BehaviorRelay<Bool>(value: false)
        self.ssidTextFieldTouchedDriver = ssidTextFieldColorChangeRelay.asDriver()

        let pwTextFieldColorChangeRelay = BehaviorRelay<Bool>(value: false)
        self.pwTextFieldTouchedDriver = pwTextFieldColorChangeRelay.asDriver()

        super.init()

        // MARK: 키보드 보일 때
        keyboardWillShow
            .subscribe(onNext: { [weak self] in
                self?.keyboardVisible.accept(true)
            })
            .disposed(by: disposeBag)

        // MARK: 키보드 숨길 때
        keyboardWillHide
            .subscribe(onNext: { [weak self] in
                self?.keyboardVisible.accept(false)
            })
            .disposed(by: disposeBag)

        // MARK: SSID 텍스트 필드 입력 할 때
        ssidText
            .skip(2)
            .distinctUntilChanged()
            .subscribe(onNext:{ ssidText in
                if (ssidText != ssid) {
                    btnColorChangeRelay.accept(true)
                }else {
                    btnColorChangeRelay.accept(false)
                }
            })
            .disposed(by: disposeBag)

        // MARK: PassWord 텍스트 필드 입력 할 때
        pwText
            .skip(2)
            .distinctUntilChanged()
            .subscribe(onNext:{ pwText in
                if (pwText != password) {
                    btnColorChangeRelay.accept(true)
                } else {
                    btnColorChangeRelay.accept(false)
                }
            })
            .disposed(by: disposeBag)

        // MARK: SSID 텍스트 필드 터치 할 때
        ssidFieldTouched
            .subscribe(onNext: { () in
                ssidTextFieldColorChangeRelay.accept(true)
                pwTextFieldColorChangeRelay.accept(false)
            })
            .disposed(by: disposeBag)

        // MARK: PassWord 텍스트 필드 터치 할 때
        pwFieldTouched
            .subscribe(onNext: { () in
                ssidTextFieldColorChangeRelay.accept(false)
                pwTextFieldColorChangeRelay.accept(true)
            })
            .disposed(by: disposeBag)

        // MARK: 카메라 버튼이 눌렸을 때
        cameraButtonTapped
            .subscribe(onNext: { [weak self] in
                self?.coordinatorController?.performFinish(to: .popToRoot)
            })
            .disposed(by: disposeBag)

        // MARK: 재연결 버튼이 눌렸을 때
        reConnectButtonTapped
            .withLatestFrom(Observable.combineLatest(self.photoImage, self.ssidText, self.pwText))
            .subscribe(onNext: { [weak self] image, ssid, password in
                guard let self = self else { return }
                self.coordinatorController?.performTransition(to: .connecting(
                    imageData: image,
                    ssid: ssid,
                    password: password
                ))
            })
            .disposed(by: disposeBag)
    }

    public func prepareLiveText(from image: UIImage) {
        Task {
            do {
                let configuration = ImageAnalyzer.Configuration([.text]) // 텍스트만 분석
                let analysis = try await ImageAnalyzer().analyze(image, configuration: configuration)

                // 분석 결과를 Relay에 저장
                DispatchQueue.main.async {
                    self.liveTextAnalysis.accept(analysis)
                }
            } catch {
                print("Live Text analysis failed: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.liveTextAnalysis.accept(nil)
                }
            }
        }
    }
}
