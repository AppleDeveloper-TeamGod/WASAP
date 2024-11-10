//
//  SharingView.swift
//  Wasap
//
//  Created by Chang Jonghyeon on 11/10/24.
//

import UIKit
import SnapKit

class SharingView: BaseView {
    lazy var peerCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .neutralBlack
        label.font = FontStyle.title.font
        label.addLabelSpacing(fontStyle: FontStyle.title)
        label.textAlignment = .center
        return label
    }()

    func setViewHierarchy() {
        self.addSubViews(peerCountLabel)
    }
    
    func setConstraints() {
        peerCountLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
}
