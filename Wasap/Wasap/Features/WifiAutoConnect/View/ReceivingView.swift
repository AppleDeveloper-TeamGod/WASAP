//
//  ReceivingView.swift
//  Wasap
//
//  Created by Chang Jonghyeon on 11/10/24.
//

import UIKit
import SnapKit
import Lottie

class ReceivingView: BaseView {
    lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .neutral100
        view.layer.cornerRadius = 40
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.neutralWhite.cgColor
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.masksToBounds = true
        return view
    }()

    lazy var xButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "SheetQuitButton"), for: .normal)
        return button
    }()

    lazy var loadingAnimation: LottieAnimationView = {
        let animation = LottieAnimationView(name: "receive")
        animation.loopMode = .playOnce
        animation.play()
        return animation
    }()

    // MARK: Check
    lazy var ssidLabel: UILabel = {
        let label = UILabel()
        label.textColor = .neutral450
        label.font = .tg22
        label.addLabelSpacing(fontStyle: .tg22)
        label.textAlignment = .center
        return label
    }()

    lazy var subLabel: UILabel = {
        let label = UILabel()
        label.text = "Wi-Fi를 공유 받았어요!".localized()
        label.textColor = .neutral400
        label.font = .tg16
        label.addLabelSpacing(fontStyle: .tg16)
        label.textAlignment = .center
        return label
    }()

    lazy var connectButton: UIButton = {
        let button = UIButton()
        button.setTitle("바로 연결하기".localized(), for: .normal)
        button.setTitleColor(.textPrimaryHigh, for: .normal)
        button.titleLabel?.font = .tg16
        button.titleLabel?.addLabelSpacing(fontStyle: .tg16)
        button.backgroundColor = .neutral500

        button.layer.cornerRadius = 25
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.clear.cgColor
        return button
    }()

    func setViewHierarchy() {
        self.addSubview(backgroundView)
        self.addSubViews(loadingAnimation, ssidLabel, subLabel, connectButton, xButton)
    }

    func setConstraints() {
        backgroundView.snp.makeConstraints { $0.edges.equalToSuperview() }

        loadingAnimation.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(ssidLabel.snp.top).offset(2)
        }

        xButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(28)
            $0.trailing.equalToSuperview().inset(24)
            $0.width.height.equalTo(26)
        }

        ssidLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(subLabel.snp.top).offset(-15)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        subLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(connectButton.snp.top).offset(-37)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        connectButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-83)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(52)
        }
    }
}
