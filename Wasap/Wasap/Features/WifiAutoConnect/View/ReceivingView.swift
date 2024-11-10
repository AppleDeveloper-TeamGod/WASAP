//
//  ReceivingView.swift
//  Wasap
//
//  Created by Chang Jonghyeon on 11/10/24.
//

import UIKit
import SnapKit

class ReceivingView: BaseView {
    lazy var connectButton: UIButton = {
        let button = UIButton()
        button.setTitle("바로 연결하기".localized(), for: .normal)
        button.setTitleColor(.textPrimaryHigh, for: .normal)
        button.titleLabel?.font = FontStyle.button.font
        button.titleLabel?.addLabelSpacing(fontStyle: FontStyle.button)
        button.backgroundColor = .buttonActivePrimaryBG
        button.isHidden = true

        button.layer.cornerRadius = 25
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.clear.cgColor
        return button
    }()

    func setViewHierarchy() {
        self.addSubViews(connectButton)
    }

    func setConstraints() {
        connectButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-82)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(52)
        }
    }
}
