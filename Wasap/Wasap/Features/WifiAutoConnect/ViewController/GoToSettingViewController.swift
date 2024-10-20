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
                    self?.goToSettingView.settingBtn.titleLabel?.font = .systemFont(ofSize: 16)
                    self?.goToSettingView.settingBtn.setTitleColor(.black, for: .normal)
                    self?.goToSettingView.settingBtn.backgroundColor = .green300
                    self?.goToSettingView.settingBtn.layer.borderWidth = 1
                    self?.goToSettingView.settingBtn.layer.borderColor = UIColor.clear.cgColor
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

        goToSettingView.xButton.rx.tap
            .bind(to: viewModel.xButtonTapped)
            .disposed(by: disposeBag)

        goToSettingView.xButton.rx.controlEvent(.touchDown)
            .subscribe(onNext: { [weak self] in
                UIView.animate(withDuration: 0.15) {
                    self?.goToSettingView.xButton.setImage(UIImage(named: "PressedQuitButton"), for: .normal)
                }
            })
            .disposed(by: disposeBag)

        goToSettingView.xButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                UIView.animate(withDuration: 0.15) {
                    self?.goToSettingView.xButton.transform = CGAffineTransform.identity
                }
            })
            .disposed(by: disposeBag)

        goToSettingView.xButton.rx.controlEvent(.touchUpOutside)
            .subscribe(onNext: { [weak self] in
                UIView.animate(withDuration: 0.15) {
                    self?.goToSettingView.xButton.transform = CGAffineTransform.identity
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

        viewModel.imageDriver
            .drive { [weak self] image in
                self?.goToSettingView.photoImageView.image = image
            }
            .disposed(by: disposeBag)
    }
}


