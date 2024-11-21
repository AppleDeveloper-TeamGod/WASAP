//
//  ToastView.swift
//  Wasap
//
//  Created by chongin on 11/9/24.
//

import UIKit

final class ToastView: BaseView {

    public lazy var toastLabel: UILabel = {
        let label = UILabel()
        label.textColor = .textPrimaryHigh
        label.font = .tg16
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.layer.cornerRadius = 20
        self.backgroundColor = .gray500
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ToastView {
    func setViewHierarchy() {
        self.addSubview(toastLabel)
    }

    func setConstraints() {
        self.toastLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
                .inset(30)
            $0.verticalEdges.equalToSuperview()
                .inset(18)
        }
    }
}
