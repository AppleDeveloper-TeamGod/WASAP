//
//  SharingView.swift
//  Wasap
//
//  Created by Chang Jonghyeon on 11/10/24.
//

import UIKit
import SnapKit
import Lottie

class SharingView: BaseView {
    lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .primary200
        return view
    }()

    lazy var firstAnimation: LottieAnimationView = {
        let animation = LottieAnimationView(name: "shareIntroAni")
        animation.loopMode = .playOnce
        animation.play { [weak self] _ in
            self?.startSecondAnimation()
        }
        return animation
    }()

    lazy var secondAnimation: LottieAnimationView = {
        let animation = LottieAnimationView(name: "shareWaveAni")
        animation.loopMode = .loop
        animation.isHidden = true
        return animation
    }()

    lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "BackButton"), for: .normal)
        return button
    }()

    lazy var shareQRButton: UIButton = {
        let button = UIButton()
        button.setTitle("QR로 공유하기".localized(), for: .normal)
        button.setTitleColor(.neutral500, for: .normal)
        button.titleLabel?.font = .tg16
        button.titleLabel?.addLabelSpacing(fontStyle: .tg16)
        return button
    }()

    // MARK:  폰트 체크
    lazy var peerCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .textPrimaryHigh
        label.font = .tg48
        label.addLabelSpacing(fontStyle: .tg48)
        label.textAlignment = .center
        label.alpha = 0.0
        label.isHidden = true
        return label
    }()

    // MARK:  폰트 체크
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "공유중!".localized()
        label.textColor = .neutral500
        label.font = .tg20
        label.addLabelSpacing(fontStyle: .tg20)
        label.textAlignment = .center
        return label
    }()

    lazy var stopShareButton: UIButton = {
        let button = UIButton()
        button.setTitle("공유 그만하기".localized(), for: .normal)
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
        self.addSubViews(secondAnimation, firstAnimation, peerCountLabel, titleLabel, stopShareButton, backButton, shareQRButton)
    }

    func setConstraints() {
        backgroundView.snp.makeConstraints { $0.edges.equalToSuperview() }

        firstAnimation.snp.makeConstraints {
            $0.centerX.equalTo(peerCountLabel.snp.centerX)
            $0.centerY.equalTo(peerCountLabel.snp.centerY)
        }

        secondAnimation.snp.makeConstraints {
            $0.centerX.equalTo(firstAnimation.snp.centerX)
            $0.centerY.equalTo(firstAnimation.snp.centerY)
        }

        backButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(68)
            $0.leading.equalToSuperview().offset(25)
            $0.height.equalTo(24)
        }

        shareQRButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(69)
            $0.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(24)
        }

        peerCountLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(357)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(105)
        }

        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(peerCountLabel.snp.bottom).offset(19)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        stopShareButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-83)
            $0.leading.trailing.equalToSuperview().inset(27)
            $0.height.equalTo(52)
        }
    }

    private func startSecondAnimation() {
        firstAnimation.isHidden = true
        secondAnimation.isHidden = false
        secondAnimation.play()

        UIView.animate(withDuration: 0.8, delay: 0.0, options: [.curveEaseInOut],
                       animations: { [weak self] in
            self?.peerCountLabel.isHidden = false
            self?.peerCountLabel.alpha = 1.0
        })
    }
}
