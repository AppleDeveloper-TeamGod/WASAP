//
//  ReceivingView.swift
//  Wasap
//
//  Created by Chang Jonghyeon on 11/10/24.
//

import UIKit
import SnapKit

class ReceivingView: BaseView {
    lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightBackground
        return view
    }()

    lazy var xButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "PressedQuitButton"), for: .normal)
        return button
    }()

    lazy var ssidLabel: UILabel = {
        let label = UILabel()
        label.textColor = .neutral500
        label.font = FontStyle.title.font
        label.addLabelSpacing(fontStyle: FontStyle.title)
        label.textAlignment = .center
        return label
    }()

    lazy var subLabel: UILabel = {
        let label = UILabel()
        label.text = "Wi-Fi를 공유 받았어요!".localized()
        label.textColor = .neutral500
        label.font = FontStyle.subTitle.font
        label.addLabelSpacing(fontStyle: FontStyle.subTitle)
        label.textAlignment = .center
        return label
    }()

    lazy var connectButton: UIButton = {
        let button = UIButton()
        button.setTitle("바로 연결하기".localized(), for: .normal)
        button.setTitleColor(.textPrimaryHigh, for: .normal)
        button.titleLabel?.font = FontStyle.button.font
        button.titleLabel?.addLabelSpacing(fontStyle: FontStyle.button)
        button.backgroundColor = .neutral500

        button.layer.cornerRadius = 25
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.clear.cgColor
        return button
    }()

    func setViewHierarchy() {
        self.addSubview(backgroundView)
        self.addSubViews(ssidLabel, subLabel, connectButton, xButton)
    }

    func setConstraints() {
        backgroundView.snp.makeConstraints { $0.edges.equalToSuperview() }

        xButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(22)
            $0.trailing.equalToSuperview().inset(22)
            $0.width.height.equalTo(24)
        }

        ssidLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(200)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        subLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(ssidLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        connectButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-83)
            $0.leading.trailing.equalToSuperview().inset(27)
            $0.height.equalTo(52)
        }
    }
}
