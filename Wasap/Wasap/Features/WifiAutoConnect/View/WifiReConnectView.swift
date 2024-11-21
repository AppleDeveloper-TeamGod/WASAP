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

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Retry!"
        label.textColor = .primary200
        label.textAlignment = .left
        label.font = .tgTitle
        label.addLabelSpacing(fontStyle: .tgTitle)
        return label
    }()

    lazy var subLabel: UILabel = {
        let label = UILabel()
        label.text = "잘못된 부분이 있나봐요!".localized()
        label.textColor = .neutral400
        label.font = .tgSubTitle
        label.addLabelSpacing(fontStyle: .tgSubTitle)
        label.textAlignment = .left
        return label
    }()

    lazy var labelStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subLabel])
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .leading
        return stackView
    }()

    lazy var photoContainerView: UIView = {
        let containerView = UIView()
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.25
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4) // 아래로 이동
        containerView.layer.shadowRadius = 4
        containerView.backgroundColor = .clear // 투명 배경
        return containerView
    }()

    lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.layer.masksToBounds = true // 둥근 모서리 내부 잘리기
        return imageView
    }()


    lazy var ssidLabel: UILabel = {
        let label = UILabel()
        label.text = "와이파이 ID".localized()
        label.textColor = .neutral200
        label.font = .tgCaption
        label.addLabelSpacing(fontStyle: .tgCaption)
        label.textAlignment = .left
        return label
    }()

    lazy var ssidField: UITextField = {
        let textField = UITextField()
        textField.textColor = .neutral200
        textField.backgroundColor = .neutral450
        textField.font = .tgPasswordM

        textField.returnKeyType = .done
        textField.layer.cornerRadius = 10
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
        label.font = .tgCaption
        label.addLabelSpacing(fontStyle: .tgCaption)
        label.textAlignment = .left
        return label
    }()

    lazy var pwField: UITextField = {
        let textField = UITextField()
        textField.textColor = .neutral200
        textField.backgroundColor = .neutral450
        textField.font = .tgPasswordM

        textField.returnKeyType = .done
        textField.layer.cornerRadius = 10
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
        button.titleLabel?.font = .tgButton
        button.titleLabel?.addLabelSpacing(fontStyle: .tgButton)
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
        backgroundView.addSubViews(labelStackView,photoContainerView,
                                   ssidStackView,pwStackView,
                                   reConnectButton,cameraButton)

        // `photoImageView`를 컨테이너에 추가
        photoContainerView.addSubview(photoImageView)

    }

    func setConstraints() {
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        cameraButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(24)
            $0.bottom.equalTo(labelStackView.snp.top).offset(-16)
            $0.width.height.equalTo(32)
        }

        labelStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalTo(photoImageView.snp.top).offset(-50)
        }

        photoContainerView.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview().inset(24)
                $0.bottom.equalTo(ssidStackView.snp.top).offset(-29)
                $0.height.equalTo(224)
            }

        photoImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview() // 컨테이너와 동일 크기
        }

        ssidStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalTo(pwStackView.snp.top).offset(-8)
            $0.height.equalTo(86)
        }

        ssidField.snp.makeConstraints {
            $0.height.equalTo(60)
            $0.width.equalTo(345)
        }

        pwStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalTo(self.keyboardLayoutGuide.snp.top).offset(-197)
            $0.height.equalTo(86)
        }

        pwField.snp.makeConstraints {
            $0.height.equalTo(60)
            $0.width.equalTo(345)
        }

        reConnectButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().offset(-83)
            $0.height.equalTo(52)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        photoContainerView.applyShadow(
            offset: CGSize(width: 0, height: 4), // x: 0, y: 4
            radius: 4,                          // 블러 반경
            color: .black,                      // 그림자 색상
            opacity: 0.25                       // 투명도
        )
    }
}
