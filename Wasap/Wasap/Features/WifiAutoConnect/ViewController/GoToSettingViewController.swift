//
//  GoToSettingViewController.swift
//  Wasap
//
//  Created by 김상준 on 10/15/24.
//

import UIKit
import RxSwift
import SnapKit

public class GoToSettingViewController: RxBaseViewController<GoToSettingViewModel>{

    private let goToSettingView = GoToSettingView()

    public override func viewDidLoad() {
        super.viewDidLoad()
    }

    public override func loadView() {
        super.loadView()
        self.view = goToSettingView
    }

    override init(viewModel: GoToSettingViewModel) {
        super.init(viewModel: viewModel)
        bind(viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func bind(_ viewModel: GoToSettingViewModel) {
        // MARK: ViewController -> ViewModel

        // MARK: settingButton
        goToSettingView.settingButton.rx.tap
            .bind(to: viewModel.setButtonTapped)
            .disposed(by: disposeBag)

        goToSettingView.settingButton.rx.controlEvent(.touchDown)
            .subscribe(onNext: { [weak self] in
                UIView.animate(withDuration: 0.15) {
                    self?.goToSettingView.settingButton.transform = CGAffineTransform(scaleX: 1, y: 0.95)
                    self?.goToSettingView.settingButton.titleLabel?.font = .tg16
                    self?.goToSettingView.settingButton.titleLabel?.addLabelSpacing(fontStyle: .tg16)
                }
            })
            .disposed(by: disposeBag)

        goToSettingView.settingButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                UIView.animate(withDuration: 0.15) {
                    self?.goToSettingView.settingButton.transform = CGAffineTransform.identity
                    self?.goToSettingView.settingButton.backgroundColor = .primary200
                }
            })
            .disposed(by: disposeBag)

        goToSettingView.settingButton.rx.controlEvent(.touchUpOutside)
            .subscribe(onNext: { [weak self] in
                UIView.animate(withDuration: 0.15) {
                    self?.goToSettingView.settingButton.transform = CGAffineTransform.identity
                    self?.goToSettingView.settingButton.backgroundColor = .primary200
                }
            })
            .disposed(by: disposeBag)

        // MARK: copyButton
        goToSettingView.copyButton.rx.tap
            .bind(to: viewModel.copyButtonTapped)
            .disposed(by: disposeBag)

        goToSettingView.copyButton.rx.controlEvent(.touchDown)
            .subscribe(onNext: { [weak self] in
                UIView.animate(withDuration: 0.15) {
                    self?.goToSettingView.copyButton.transform = CGAffineTransform(scaleX: 1, y: 0.95)
                }
            })
            .disposed(by: disposeBag)

        goToSettingView.copyButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                UIView.animate(withDuration: 0.15) {
                    self?.goToSettingView.settingButton.transform = CGAffineTransform.identity
                    self?.goToSettingView.copyButton.setImage(UIImage(named: "CheckIcon"), for: .normal)
                    self?.goToSettingView.copyButton.setTitle("", for: .normal)
                    self?.goToSettingView.copyButton.backgroundColor = .green500
                }
            })
            .disposed(by: disposeBag)

        goToSettingView.copyButton.rx.controlEvent(.touchUpOutside)
            .subscribe(onNext: { [weak self] in
                UIView.animate(withDuration: 0.15) {
                    self?.goToSettingView.settingButton.transform = CGAffineTransform.identity
                    self?.goToSettingView.copyButton.setImage(UIImage(named: "CheckIcon"), for: .normal)
                    self?.goToSettingView.copyButton.setTitle("", for: .normal)
                    self?.goToSettingView.copyButton.backgroundColor = .green500
                }
            })
            .disposed(by: disposeBag)

        // MARK: cameraButton
        goToSettingView.cameraButton.rx.tap
            .bind(to: viewModel.cameraButtonTapped)
            .disposed(by: disposeBag)

        goToSettingView.cameraButton.rx.controlEvent(.touchDown)
            .subscribe(onNext: { [weak self] in
                UIView.animate(withDuration: 0.15) {
                    self?.goToSettingView.cameraButton.setImage(UIImage(named: "PressedGoCameraButton"), for: .normal)
                }
            })
            .disposed(by: disposeBag)

        goToSettingView.cameraButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                UIView.animate(withDuration: 0.15) {
                    self?.goToSettingView.cameraButton.setImage(UIImage(named: "GoCameraButton"), for: .normal)
                }
            })
            .disposed(by: disposeBag)

        goToSettingView.cameraButton.rx.controlEvent(.touchUpOutside)
            .subscribe(onNext: { [weak self] in
                UIView.animate(withDuration: 0.15) {
                    self?.goToSettingView.cameraButton.setImage(UIImage(named: "GoCameraButton"), for: .normal)
                }
            })
            .disposed(by: disposeBag)

        // MARK: backButton
        goToSettingView.backButton.rx.tap
            .bind(to: viewModel.backButtonTapped)
            .disposed(by: disposeBag)

        goToSettingView.backButton.rx.controlEvent(.touchDown)
            .subscribe(onNext: { [weak self] in
                UIView.animate(withDuration: 0.15) {
                    self?.goToSettingView.backButton.transform = CGAffineTransform(scaleX: 1, y: 0.95)
                }
            })
            .disposed(by: disposeBag)

        goToSettingView.backButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                UIView.animate(withDuration: 0.15) {
                    self?.goToSettingView.backButton.transform = CGAffineTransform.identity
                }
            })
            .disposed(by: disposeBag)

        goToSettingView.backButton.rx.controlEvent(.touchUpOutside)
            .subscribe(onNext: { [weak self] in
                UIView.animate(withDuration: 0.15) {
                    self?.goToSettingView.backButton.transform = CGAffineTransform.identity
                }
            })
            .disposed(by: disposeBag)

        // MARK: ViewModel -> ViewController

        viewModel.ssidDriver
            .drive { [ weak self] ssid in
                self?.goToSettingView.ssidFieldLabel.text = ssid
            }
            .disposed(by: disposeBag)

        viewModel.passwordDriver
            .drive { [ weak self] password in
                self?.goToSettingView.pwFieldLabel.text = password
            }
            .disposed(by: disposeBag)
    }
}


