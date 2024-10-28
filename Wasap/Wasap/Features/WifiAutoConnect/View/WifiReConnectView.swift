//
//  WifiReConnectView.swift
//  Wasap
//
//  Created by 김상준 on 10/6/24.
//
import UIKit
import SnapKit

class WifiReConnectView: BaseView {

    lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkBackground
        return view
    }()

    lazy var cameraButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "GoCameraButton"), for: .normal)
        return button
    }()

    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "RetryViewIcon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Retry"
        label.textColor = .primary200
        label.textAlignment = .left
        label.font = FontStyle.title.font
        label.addLabelSpacing(fontStyle: FontStyle.title)
        return label
    }()

    lazy var titleStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [iconImageView, titleLabel])
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.spacing = 3
        return stackView
    }()

    lazy var subLabel: UILabel = {
        let label = UILabel()
        label.text = "잘못된 부분이 있나봐요!".localized()
        label.textColor = .neutral400
        label.font = FontStyle.subTitle.font
        label.addLabelSpacing(fontStyle: FontStyle.subTitle)
        label.textAlignment = .left
        return label
    }()

    lazy var labelStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleStackView, subLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .leading
        return stackView
    }()

    lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "RetryViewPhoto")
        imageView.layer.borderColor = UIColor.green200.cgColor
        imageView.layer.borderWidth = 3.0
        return imageView
    }()

    lazy var ssidLabel: UILabel = {
        let label = UILabel()
        label.text = "와이파이 ID".localized()
        label.textColor = .neutral200
        label.font = FontStyle.caption.font
        label.addLabelSpacing(fontStyle: FontStyle.caption)
        label.textAlignment = .left
        return label
    }()

    lazy var ssidField: UITextField = {
        let textField = UITextField()
        textField.textColor = .neutral200
        textField.backgroundColor = .neutral450
        textField.font = FontStyle.password_M.font

        textField.returnKeyType = .done
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        textField.textAlignment = .center

        return textField
    }()

    lazy var ssidStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [ssidLabel, ssidField])
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()

    lazy var pwLabel: UILabel = {
        let label = UILabel()
        label.text = "비밀번호".localized()
        label.textColor = .neutral200
        label.font = FontStyle.caption.font
        label.addLabelSpacing(fontStyle: FontStyle.caption)
        label.textAlignment = .left
        return label
    }()

    lazy var pwField: UITextField = {
        let textField = UITextField()
        textField.textColor = .neutral200
        textField.backgroundColor = .neutral450
        textField.font = FontStyle.password_M.font

        textField.returnKeyType = .done
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        textField.textAlignment = .center

        return textField
    }()

    lazy var pwStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [pwLabel, pwField])
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()

    lazy var reConnectButton: UIButton = {
        let button = UIButton()
        button.setTitle("다시 연결하기".localized(), for: .normal)
        button.setTitleColor(.neutral200, for: .normal)
        button.titleLabel?.font = FontStyle.button.font
        button.titleLabel?.addLabelSpacing(fontStyle: FontStyle.button)
        button.backgroundColor = .clear

        button.layer.cornerRadius = 25
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.neutral200.cgColor
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setViewHierarchy()
        setConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setViewHierarchy() {
        self.addSubview(backgroundView)
        backgroundView.addSubViews(labelStackView,photoImageView,
                                   ssidStackView,pwStackView,
                                   reConnectButton,cameraButton)
    }

    func setConstraints() {
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        cameraButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(68)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.height.equalTo(32)
        }

        iconImageView.snp.makeConstraints {
            $0.width.height.equalTo(26)
        }

        titleStackView.snp.makeConstraints {
            $0.height.equalTo(36)
        }

        labelStackView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.bottom.equalTo(photoImageView.snp.top).offset(-53)
            $0.height.equalTo(63)
        }

        photoImageView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(31)
            $0.bottom.equalTo(ssidStackView.snp.top).offset(-54)
            $0.height.equalTo(216)
        }

        ssidStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(31)
            $0.bottom.equalTo(pwStackView.snp.top).offset(-16)
            $0.height.equalTo(78)
        }

        ssidField.snp.makeConstraints {
            $0.height.equalTo(60)
            $0.width.equalTo(330)
        }

        pwStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(31)
            $0.bottom.equalTo(self.keyboardLayoutGuide.snp.top).offset(-187)
            $0.height.equalTo(78)
        }

        pwField.snp.makeConstraints {
            $0.height.equalTo(60)
            $0.width.equalTo(330)
        }

        reConnectButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-82)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(52)
        }
    }
}
