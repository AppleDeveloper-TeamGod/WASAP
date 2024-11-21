//
//  ConnectingView.swift
//  Wasap
//
//  Created by Chang Jonghyeon on 10/14/24.
//

import UIKit
import SnapKit
import Lottie

class ConnectingView: BaseView {
    lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkBackground
        return view
    }()

    lazy var loadingAnimation: LottieAnimationView = {
        let animation = LottieAnimationView(name: "connectAni")
        animation.loopMode = .loop
        animation.play()
        return animation
    }()

    lazy var quitButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "QuitButtonGray"), for: .normal)
        button.isHidden = true
        return button
    }()

    lazy var mainStatusLabel: UILabel = {
        let label = UILabel()
        label.text = "Done!"
        label.textColor = .neutral500
        label.font = .tgTitle.withSize(48)
        label.addLabelSpacing(fontStyle: .tgTitle)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    lazy var subStatusLabel: UILabel = {
        let label = UILabel()
        label.text = "연결 되었어요!".localized()
        label.textColor = .neutral500
        label.font = .tgSubTitle
        label.addLabelSpacing(fontStyle: .tgSubTitle)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    lazy var shareButton: UIButton = {
        let button = UIButton()
        button.setTitle("Wi-Fi 공유하기".localized(), for: .normal)
        button.setTitleColor(.textPrimaryHigh, for: .normal)
        button.titleLabel?.font = .tgButton
        button.titleLabel?.addLabelSpacing(fontStyle: .tgButton)
        button.backgroundColor = .neutral500
        button.isHidden = true

        button.layer.cornerRadius = 25
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.clear.cgColor
        return button
    }()

    func setViewHierarchy() {
        self.addSubview(backgroundView)
        self.addSubViews(loadingAnimation, mainStatusLabel, subStatusLabel, quitButton, shareButton)
    }

    func setConstraints() {
        backgroundView.snp.makeConstraints { $0.edges.equalToSuperview() }

        loadingAnimation.snp.makeConstraints { $0.edges.equalToSuperview() }

        quitButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(71)
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.equalTo(26)
            $0.height.equalTo(26)
        }

        mainStatusLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(384)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(45)
        }

        subStatusLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(mainStatusLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(20)
        }

        shareButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-82)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(52)
        }
    }
}
