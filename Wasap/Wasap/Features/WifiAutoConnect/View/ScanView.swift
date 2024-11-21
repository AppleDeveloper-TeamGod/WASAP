//
//  ScanView.swift
//  Wasap
//
//  Created by Chang Jonghyeon on 10/10/24.
//

import UIKit
import SnapKit
import Lottie

class ScanView: BaseView {
    lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray500
        return view
    }()
    
    lazy var previewView: UIImageView = {
        let previewView = UIImageView()
        previewView.contentMode = .scaleAspectFill
        previewView.layer.borderWidth = 3.0
        previewView.layer.borderColor = UIColor.green200.cgColor
        previewView.layer.masksToBounds = true
        return previewView
    }()
    
    lazy var scanIcon: UIImageView = {
        let icon = UIImageView(image: UIImage(named: "ScanIcon"))
        return icon
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "SCAN"
        label.textColor = .textPrimaryHigh
        label.font = .tg22
        label.addLabelSpacing(fontStyle: .tg22)
        return label
    }()
    
    lazy var subLabel: UILabel = {
        let label = UILabel()
        label.text = "스캔 완료!".localized()
        label.textColor = .textNeutralHigh
        label.font = .tg16
        label.addLabelSpacing(fontStyle: .tg16)
        label.textAlignment = .center
        return label
    }()
    
    func setViewHierarchy() {
        self.addSubview(backgroundView)
        self.addSubViews(previewView, scanIcon, titleLabel, subLabel)
    }
    
    func setConstraints() {
        backgroundView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        previewView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(249)
            $0.width.equalTo(331)
            $0.height.equalTo(216)
        }
        
        scanIcon.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(previewView.snp.bottom).offset(31)
            $0.width.equalTo(20)
            $0.height.equalTo(20)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(scanIcon.snp.bottom).offset(9)
            $0.width.equalTo(88)
            $0.height.equalTo(36)
        }
        
        subLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(7)
            $0.trailing.leading.equalToSuperview().inset(20)
            $0.height.equalTo(22)
        }

    }
}
