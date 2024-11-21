//
//  SharingQRView.swift
//  Wasap
//
//  Created by Chang Jonghyeon on 11/11/24.
//

import UIKit
import SnapKit

class SharingQRView: BaseView {
    lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightBackground
        return view
    }()

    lazy var xButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "SheetQuitButton"), for: .normal)
        return button
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "QR로 공유하기".localized()
        label.textColor = .neutral500
        label.font = .tg22
        label.addLabelSpacing(fontStyle: .tg22)
        label.textAlignment = .center
        return label
    }()

    lazy var qrCodeView: UIImageView = {
        let qrView = UIImageView()
        qrView.contentMode = .scaleAspectFit
        qrView.layer.borderWidth = 6.0
        qrView.layer.borderColor = UIColor.green200.cgColor
        qrView.layer.masksToBounds = true
        return qrView
    }()

    lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setTitle("닫기".localized(), for: .normal)
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
        self.addSubViews(titleLabel, closeButton, qrCodeView, xButton)
    }

    func setConstraints() {
        backgroundView.snp.makeConstraints { $0.edges.equalToSuperview() }

        xButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(22)
            $0.trailing.equalToSuperview().inset(15)
            $0.width.height.equalTo(34)
        }

        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(qrCodeView.snp.top).offset(-30)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.width.equalTo(178)
            $0.height.equalTo(25)
        }

        qrCodeView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(closeButton.snp.top).offset(-153)
            $0.width.equalTo(275)
            $0.height.equalTo(275)
        }

        closeButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-83)
            $0.leading.trailing.equalToSuperview().inset(27)
            $0.height.equalTo(52)
        }
    }
}
