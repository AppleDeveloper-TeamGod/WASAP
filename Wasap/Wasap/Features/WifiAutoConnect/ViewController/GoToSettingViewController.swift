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
        goToSettingView.settingBtn.rx.tap
            .bind(to: viewModel.setButtonTapped)
            .disposed(by: disposeBag)

        goToSettingView.settingBtn.rx.controlEvent(.touchDown)
            .subscribe(onNext: { [weak self] in
                UIView.animate(withDuration: 0.15) {
                    self?.goToSettingView.settingBtn.transform = CGAffineTransform(scaleX: 1, y: 0.95)
                    self?.goToSettingView.settingBtn.titleLabel?.font = FontStyle.button.font
                    self?.goToSettingView.settingBtn.titleLabel?.addLabelSpacing(fontStyle: FontStyle.button)
                    self?.goToSettingView.settingBtn.setTitleColor(.black, for: .normal)
                    self?.goToSettingView.settingBtn.backgroundColor = .green300
                    self?.goToSettingView.settingBtn.layer.borderWidth = 1
                    self?.goToSettingView.settingBtn.layer.borderColor = UIColor.clear.cgColor
                }
            })
            .disposed(by: disposeBag)

        goToSettingView.copyButton.rx.tap
            .bind(to: viewModel.copyButtonTapped)
            .disposed(by: disposeBag)

        goToSettingView.copyButton.rx.controlEvent(.touchDown)
            .subscribe(onNext: { [weak self] in
                UIView.animate(withDuration: 0.15) {
                    self?.goToSettingView.copyButton.setImage(UIImage(named: "check"), for: .normal)
                    self?.goToSettingView.copyButton.setTitle("", for: .normal)
                    self?.goToSettingView.copyButton.backgroundColor = .black
                }
            })
            .disposed(by: disposeBag)

        goToSettingView.settingBtn.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                UIView.animate(withDuration: 0.15) {
                    self?.goToSettingView.settingBtn.transform = CGAffineTransform.identity
                    self?.goToSettingView.settingBtn.backgroundColor = .primary200
                }
            })
            .disposed(by: disposeBag)

        goToSettingView.settingBtn.rx.controlEvent(.touchUpOutside)
            .subscribe(onNext: { [weak self] in
                UIView.animate(withDuration: 0.15) {
                    self?.goToSettingView.settingBtn.transform = CGAffineTransform.identity
                    self?.goToSettingView.settingBtn.backgroundColor = .primary200
                }
            })
            .disposed(by: disposeBag)

        goToSettingView.cameraBtn.rx.tap
            .bind(to: viewModel.cameraButtonTapped)
            .disposed(by: disposeBag)

        goToSettingView.backBtn.rx.tap
            .bind(to: viewModel.backButtonTapped)
            .disposed(by: disposeBag)

        goToSettingView.cameraBtn.rx.controlEvent(.touchDown)
            .subscribe(onNext: { [weak self] in
                UIView.animate(withDuration: 0.15) {
                    self?.goToSettingView.cameraBtn.setImage(UIImage(named: "PressedQuitButton"), for: .normal)
                }
            })
            .disposed(by: disposeBag)

        goToSettingView.cameraBtn.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                UIView.animate(withDuration: 0.15) {
                    self?.goToSettingView.cameraBtn.transform = CGAffineTransform.identity
                }
            })
            .disposed(by: disposeBag)

        goToSettingView.cameraBtn.rx.controlEvent(.touchUpOutside)
            .subscribe(onNext: { [weak self] in
                UIView.animate(withDuration: 0.15) {
                    self?.goToSettingView.cameraBtn.transform = CGAffineTransform.identity
                }
            })
            .disposed(by: disposeBag)

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


