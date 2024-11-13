//
//  ViewController.swift
//  Wasap
//
//  Created by chongin on 10/3/24.
//
import UIKit
import RxSwift
import SnapKit
import RxGesture
import VisionKit

public class WifiReConnectViewController: RxBaseViewController<WifiReConnectViewModel>{

    private let wifiReConnectView = WifiReConnectView()
    private let imageAnalyzer = ImageAnalyzer()

    // MARK: VisionKit
    private let interaction: ImageAnalysisInteraction = {
        let interaction = ImageAnalysisInteraction()
        interaction.preferredInteractionTypes = .automatic // 자동으로 텍스트 상호작용 활성화
        return interaction
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardNotifications()
        view.keyboardLayoutGuide.usesBottomSafeArea = false

        // Live Text 상호작용 추가
        wifiReConnectView.photoImageView.addInteraction(interaction)
        // 이미지 분석 시작
        analyzeImageForText()
    }

    public override func loadView() {
        super.loadView()
        self.view = wifiReConnectView
    }

    override init(viewModel: WifiReConnectViewModel) {
        super.init(viewModel: viewModel)
        bind(viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func bind(_ viewModel: WifiReConnectViewModel) {
        // MARK: SSID 값이 변경될 때 마다 ViewModel로 전달
        wifiReConnectView.ssidField.rx.text.orEmpty
            .bind(to: viewModel.ssidText)
            .disposed(by: disposeBag)

        // MARK: SSID FIELD 터치
        wifiReConnectView.ssidField.rx.controlEvent(.editingDidBegin)
            .bind(to: viewModel.ssidFieldTouched)
            .disposed(by: disposeBag)

        // MARK: PASSWORD 값이 변경될 때 마다 ViewModel로 전달
        wifiReConnectView.pwField.rx.text.orEmpty
            .bind(to: viewModel.pwText)
            .disposed(by: disposeBag)

        // MARK: PASSWORD FIELD 터치
        wifiReConnectView.pwField.rx.controlEvent(.editingDidBegin)
            .bind(to: viewModel.pwFieldTouched)
            .disposed(by: disposeBag)

        // MARK: ReConnect 버튼이 눌렸을 때 ViewModel 트리거
        wifiReConnectView.reConnectButton.rx.tap
            .subscribe(onNext: { [weak self] in
                // 텍스트 필드를 작동시키지 않아도 현재 값을 넘기기 위한 의도
                let currentSSID = self?.wifiReConnectView.ssidField.text ?? ""
                let currentPassword = self?.wifiReConnectView.pwField.text ?? ""
                let currentImage = self?.wifiReConnectView.photoImageView.image ?? UIImage()

                // ViewModel에 값 반영
                viewModel.ssidText.accept(currentSSID)
                viewModel.pwText.accept(currentPassword)
                viewModel.photoImage.accept(currentImage)

                // ViewModel의 버튼 탭 이벤트 트리거
                viewModel.reConnectButtonTapped.accept(())
            })
            .disposed(by: disposeBag)

        wifiReConnectView.reConnectButton.rx.controlEvent(.touchDown)
            .subscribe(onNext: { [weak self] in
                UIView.animate(withDuration: 0.15) {
                    self?.wifiReConnectView.reConnectButton.transform = CGAffineTransform(scaleX: 1, y: 0.95)
                    self?.wifiReConnectView.reConnectButton.setTitleColor(.black, for: .normal)
                    self?.wifiReConnectView.reConnectButton.titleLabel?.font = FontStyle.button.font
                    self?.wifiReConnectView.reConnectButton.titleLabel?.addLabelSpacing(fontStyle: FontStyle.button)
                    self?.wifiReConnectView.reConnectButton.backgroundColor = .green300

                    self?.wifiReConnectView.reConnectButton.layer.borderWidth = 1
                    self?.wifiReConnectView.reConnectButton.layer.borderColor = UIColor.clear.cgColor
                }
            })
            .disposed(by: disposeBag)

        wifiReConnectView.reConnectButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                UIView.animate(withDuration: 0.15) {
                    self?.wifiReConnectView.reConnectButton.transform = CGAffineTransform.identity
                    self?.wifiReConnectView.reConnectButton.backgroundColor = .primary200
                }
            })
            .disposed(by: disposeBag)

        wifiReConnectView.reConnectButton.rx.controlEvent(.touchUpOutside)
            .subscribe(onNext: { [weak self] in
                UIView.animate(withDuration: 0.15) {
                    self?.wifiReConnectView.reConnectButton.transform = CGAffineTransform.identity
                    self?.wifiReConnectView.reConnectButton.backgroundColor = .primary200
                }
            })
            .disposed(by: disposeBag)

        // MARK: BackGround 터치하면 ViewModel 트리거
        //        wifiReConnectView.backgroundView.rx.tapGesture()
        //            .when(.recognized)
        //            .map { _ in } // 이벤트를 빈 값으로 변환하여 Relay로 전달
        //            .bind(to: viewModel.bgTouched)
        //            .disposed(by: disposeBag)

        // MARK: CameraBtn 터치하면 ViewModel 트리거
        wifiReConnectView.cameraButton.rx.tap
            .bind(to: viewModel.cameraButtonTapped)
            .disposed(by: disposeBag)

        // MARK: CameraBtn 터치시 이벤트
        wifiReConnectView.cameraButton.rx.controlEvent(.touchDown)
            .subscribe(onNext: { [weak self] in
                UIView.animate(withDuration: 0.15) {
                    self?.wifiReConnectView.cameraButton.setImage(UIImage(named: "PressedGoCameraButton"), for: .normal)
                }
            })
            .disposed(by: disposeBag)

        // MARK: CameraBtn 땔 시 이벤트
        wifiReConnectView.cameraButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                UIView.animate(withDuration: 0.15) {
                    self?.wifiReConnectView.cameraButton.transform = CGAffineTransform.identity
                }
            })
            .disposed(by: disposeBag)

        // MARK: CameraBtn 땔 시 이벤트
        wifiReConnectView.cameraButton.rx.controlEvent(.touchUpOutside)
            .subscribe(onNext: { [weak self] in
                UIView.animate(withDuration: 0.15) {
                    self?.wifiReConnectView.cameraButton.transform = CGAffineTransform.identity
                }
            })
            .disposed(by: disposeBag)

        // MARK: ViewModel에서 Keyboard hide 전달 받기
        viewModel.bgTouchedDriver
            .drive(onNext: { [weak self] isTouch in
                self?.wifiReConnectView.endEditing(true)
            })
            .disposed(by: disposeBag)

        // MARK: ViewModel에서 버튼 색상 상태를 구독하여 UI 업데이트
        viewModel.btnColorChangeDriver
            .drive(onNext: { [weak self] isEnabled in
                guard let self = self else { return }
                self.wifiReConnectView.reConnectButton.backgroundColor = isEnabled ? .green200 : .clear
                self.wifiReConnectView.reConnectButton.setTitleColor(isEnabled ? .black : .neutral200, for: .normal)
                self.wifiReConnectView.reConnectButton.layer.borderColor = isEnabled ? UIColor.clear.cgColor : UIColor.neutral200.cgColor
            })
            .disposed(by: disposeBag)

        // MARK: ViewModel로부터 SSID 값 전달 받기
        viewModel.ssidDriver
            .drive(wifiReConnectView.ssidField.rx.text)
            .disposed(by: disposeBag)

        // MARK: ViewModel로부터 SSID COLOR 값 전달 받기
        viewModel.ssidTextFieldTouchedDriver
            .drive(onNext: { [weak self] isEnabled in

                self?.wifiReConnectView.ssidField.layer.borderColor = isEnabled ? UIColor.green200.cgColor : UIColor.neutral200.cgColor

                self?.wifiReConnectView.ssidField.layer.borderWidth = isEnabled ? 4 : 0

                /// 공백 처리 로직
                if(isEnabled) {
                    if let copiedStr = UIPasteboard.general.string {
                        let textWithoutSpaces = copiedStr.replacingOccurrences(of: " ", with: "")
                        UIPasteboard.general.string = textWithoutSpaces
                    }
                }
            })
            .disposed(by: disposeBag)

        // MARK: ViewModel로 부터 PASSWORD 값 전달 받기
        viewModel.passwordDriver
            .drive(wifiReConnectView.pwField.rx.text)
            .disposed(by: disposeBag)

        // MARK: ViewModel로부터 PASSWORD COLOR 값 전달 받기
        viewModel.pwTextFieldTouchedDriver
            .drive(onNext: { [weak self] isEnabled in

                self?.wifiReConnectView.pwField.layer.borderColor = isEnabled ? UIColor.green200.cgColor :  UIColor.neutral200.cgColor

                self?.wifiReConnectView.pwField.layer.borderWidth = isEnabled ? 4 : 0

                /// 공백 처리 로직
                if(isEnabled) {
                    if let copiedStr = UIPasteboard.general.string {
                        let textWithoutSpaces = copiedStr.replacingOccurrences(of: " ", with: "")
                        UIPasteboard.general.string = textWithoutSpaces
                    }
                }
            })
            .disposed(by: disposeBag)

        // MARK: ViewModel로 부터 이미지 값 전달 받기
        viewModel.updatedImageDriver
            .drive(wifiReConnectView.photoImageView.rx.image)
            .disposed(by: disposeBag)

        // MARK: ViewModel로 부터 Keyboard Visible 값 전달 받기
        viewModel.keyboardVisible
            .subscribe(onNext: { [weak self] isVisible in
                if isVisible {
                    self?.handleKeyboardWillShow()
                } else {
                    self?.handleKeyboardWillHide()
                }
            })
            .disposed(by: disposeBag)
    }

    //MARK: 키보드 세팅
    private func setupKeyboardNotifications() {
        // 키보드 나타나는 이벤트 처리
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillShowNotification)
            .map { _ in } // Void로 변환하여 ViewModel로 전달
            .bind(to: viewModel.keyboardWillShow)
            .disposed(by: disposeBag)

        // 키보드 숨김 이벤트 처리
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillHideNotification)
            .map { _ in } // Void로 변환하여 ViewModel로 전달
            .bind(to: viewModel.keyboardWillHide)
            .disposed(by: disposeBag)
    }

    // MARK: 키보드 보일 때 처리
    private func handleKeyboardWillShow() {
        wifiReConnectView.pwStackView.snp.remakeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalTo(self.view.keyboardLayoutGuide.snp.top).offset(-24)
        }

        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut], animations: {
            self.view.layoutIfNeeded()

            self.wifiReConnectView.labelStackView.alpha = 0
            self.wifiReConnectView.cameraButton.alpha = 0
        })
    }

    // MARK: 키보드 숨길 때 처리
    private func handleKeyboardWillHide() {
        resetViewState()

        wifiReConnectView.pwStackView.snp.remakeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalTo(self.view.keyboardLayoutGuide.snp.top).offset(-197)
        }

        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut], animations: {
            self.view.layoutIfNeeded()

            self.wifiReConnectView.labelStackView.alpha = 1
            self.wifiReConnectView.cameraButton.alpha = 1

        })
    }

    // MARK: 원래 화면으로 복원
    private func resetViewState() {
        wifiReConnectView.ssidField.textColor = .neutral200
        wifiReConnectView.ssidField.textAlignment = .center
        wifiReConnectView.ssidField.layer.borderColor = UIColor.clear.cgColor

        wifiReConnectView.pwField.textColor = .neutral200
        wifiReConnectView.pwField.textAlignment = .center
        wifiReConnectView.pwField.layer.borderColor = UIColor.clear.cgColor
    }

    private func analyzeImageForText() {
        guard let image = wifiReConnectView.photoImageView.image else { return }

        Task {
            let configuration = ImageAnalyzer.Configuration([.text]) // 텍스트만 분석하도록 설정
            // 이미지 분석 수행
            let analysis = try await self.imageAnalyzer.analyze(image, configuration: configuration)
            DispatchQueue.main.async {
                // 분석 결과를 ImageAnalysisInteraction에 연결하여 상호작용 가능하게 함
                self.interaction.analysis = analysis
            }
        }
    }

    // MARK: 키보드 deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
