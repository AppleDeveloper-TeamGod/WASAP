//
//  GoToSettingView.swift
//  Wasap
//
//  Created by 김상준 on 10/15/24.
//
import UIKit
import SnapKit

class GoToSettingView: BaseView {

    lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkBackground
        return view
    }()

    lazy var cameraButton : UIButton = {
        let button = UIButton()
        button.setImage(
            UIImage(named: "GoCameraButton"), for: .normal)
        return button
    }()

    lazy var infoIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "InfoTextIcon")
        return imageView
    }()

    lazy var titleLabel1: UILabel = {
        let label = UILabel()
        label.text = "인식된 정보를 확인하고,"
        label.textColor = .gray200
        label.textAlignment = .left
        label.font = .tg22
        label.addLabelSpacing(fontStyle: .tg22)
        return label
    }()

    lazy var titleLabel2: UILabel = {
        let label = UILabel()
        label.text = "설정에서 시도하세요."
        label.textColor = .green300
        label.textAlignment = .left
        label.font = .tg22
        label.addLabelSpacing(fontStyle: .tg22)
        return label
    }()

    lazy var titleStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel1, titleLabel2])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 4
        return stackView
    }()

    lazy var memoView: UIView = {
        let view = UIView()
        view.backgroundColor = .neutral450
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = false // Gradient를 위해 false 설정
        return view
    }()

    lazy var memoText: UILabel = {
        let label = UILabel()
        label.text = "Wi-Fi 정보"
        label.textColor = .gray100
        label.font = .tg16
        label.addLabelSpacing(fontStyle: .tg16)
        label.textAlignment = .left
        return label
    }()

    lazy var ssidLabel: UILabel = {
        let label = UILabel()
        label.text = "와이파이 ID"
        label.textColor = .gray400
        label.font = .tg12
        label.addLabelSpacing(fontStyle: .tg12)
        label.textAlignment = .left
        return label
    }()

    lazy var ssidFieldLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray300
        label.font = .tgPasswordS
        label.addLabelSpacing(fontStyle: .tgPasswordS)
        label.textAlignment = .left
        return label
    }()

    lazy var ssidStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [ssidLabel, ssidFieldLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()

    lazy var pwLabel: UILabel = {
        let label = UILabel()
        label.text = "비밀번호"
        label.textColor = .gray400
        label.font = .tg12
        label.addLabelSpacing(fontStyle: .tg12)
        label.textAlignment = .left
        return label
    }()

    lazy var pwFieldLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray300
        label.font = .tgPasswordS
        label.addLabelSpacing(fontStyle: .tgPasswordS)
        label.textAlignment = .left
        return label
    }()

    lazy var pwStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [pwLabel, pwFieldLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()

    lazy var copyButton: UIButton = {
        let button = UIButton()
        button.setTitle("복사하기", for: .normal)
        button.setTitleColor(.green200, for: .normal)
        button.titleLabel?.font = .tg14
        button.titleLabel?.addLabelSpacing(fontStyle: .tg14)

        button.backgroundColor = .clear

        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.green200.cgColor
        return button
    }()

    lazy var infoFirstLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .gray400
        label.textAlignment = .center
        label.text = "WiFi 비밀번호를 복사해,"
        label.font = .tg16
        label.addLabelSpacing(fontStyle: .tg16)
        return label
    }()

    lazy var infoSecondLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .gray400
        label.textAlignment = .center
        label.font = .tg16
        label.addLabelSpacing(fontStyle: .tg16)

        let wifiID = "설정 > Wi-Fi"
        let description = "\(wifiID) "+"에서 이어서 연결하세요."

        // 글자 색깔 넣기
        let attributedString = NSMutableAttributedString(string: description)
        if let wifiIDRange = description.range(of: wifiID) {
            let nsRange = NSRange(wifiIDRange, in: description)
            attributedString.addAttribute(.foregroundColor, value: UIColor.green300, range: nsRange)
        }
        label.attributedText = attributedString
        return label
    }()

    lazy var infoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [infoFirstLabel,infoSecondLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()

    lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "BackIcon"), for: .normal)
        button.titleLabel?.font = .tg16
        button.titleLabel?.addLabelSpacing(fontStyle: .tg16)
        button.setTitleColor(.primary200, for: .normal)
        button.backgroundColor = .clear

        button.layer.cornerRadius = 14
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.primary200.cgColor
        return button
    }()

    lazy var settingButton: UIButton = {
        let button = UIButton()
        button.setTitle("아이폰 설정으로 가기", for: .normal)
        button.titleLabel?.font = .tg16
        button.titleLabel?.addLabelSpacing(fontStyle: .tg16)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .primary200

        button.layer.cornerRadius = 14
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.clear.cgColor
        return button
    }()

    lazy var btnStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [backButton, settingButton])
        stackView.axis = .horizontal
        stackView.spacing = 10
        return stackView
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
        backgroundView.addSubViews(cameraButton,titleStackView,memoView,
                                   infoStackView,btnStackView)
        memoView.addSubViews(memoText,infoIcon,ssidStackView,pwStackView,copyButton)
    }

    func setConstraints() {
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        cameraButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(68)
            $0.trailing.equalToSuperview().inset(24)
            $0.width.height.equalTo(32)
        }

        titleStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(116)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(59)
        }

        memoView.snp.makeConstraints {
            $0.top.equalTo(titleStackView.snp.bottom).offset(50)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(221)
        }

        infoIcon.snp.makeConstraints {
            $0.top.equalToSuperview().inset(14)
            $0.trailing.equalToSuperview().inset(16)
            $0.width.height.equalTo(16)
        }

        memoText.snp.makeConstraints {
            $0.top.equalToSuperview().inset(32)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(26)
            $0.width.equalTo(81)
        }

        ssidStackView.snp.makeConstraints{
            $0.top.equalTo(memoText.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(48)
        }

        pwStackView.snp.makeConstraints {
            $0.top.equalTo(ssidStackView.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(16)
            $0.height.equalTo(48)
            $0.width.equalTo(220)
        }

        copyButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(27)
            $0.width.equalTo(84)
            $0.height.equalTo(38)
        }

        infoStackView.snp.makeConstraints {
            $0.top.equalTo(memoView.snp.bottom).offset(177)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(52)
            $0.width.equalTo(320)
        }

        btnStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.top.equalTo(infoStackView.snp.bottom).offset(50)
            $0.height.equalTo(52)
        }

        backButton.snp.makeConstraints {
            $0.width.equalTo(99)
        }

        settingButton.snp.makeConstraints {
            $0.width.equalTo(236)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // memoView의 테두리 그라데이션 업데이트
        memoView.applyGradientBorder(
            colors: [UIColor(red: 116/255, green: 112/255, blue: 112/255, alpha: 1.0),
                     UIColor(red: 89/255, green: 88/255, blue: 88/255, alpha: 1.0)
                    ],
            width: 1,
            cornerRadius: 20
        )
        memoView.applyShadow(
            offset: CGSize(width: 0, height: 4), // x: 0, y: 4
            radius: 4,                          // 블러 반경
            color: .black,                      // 그림자 색상
            opacity: 0.25                       // 투명도
        )
    }
}
