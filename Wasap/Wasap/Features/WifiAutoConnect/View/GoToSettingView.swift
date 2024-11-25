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
        label.font = .tg22
        label.addLabelSpacing(fontStyle: .tg22)
        label.text = "인식된 정보를 확인하고,"
        label.textColor = .gray200
        label.textAlignment = .left
        return label
    }()

    lazy var titleLabel2: UILabel = {
        let label = UILabel()
        label.font = .tg22
        label.addLabelSpacing(fontStyle: .tg22)
        label.text = "설정에서 시도하세요."
        label.textColor = .green300
        label.textAlignment = .left
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
        label.font = .tg16
        label.addLabelSpacing(fontStyle: .tg16)
        label.text = "Wi-Fi 정보"
        label.textColor = .gray100
        label.textAlignment = .left
        return label
    }()

    lazy var ssidLabel: UILabel = {
        let label = UILabel()
        label.font = .tg12
        label.addLabelSpacing(fontStyle: .tg12)
        label.text = "와이파이 ID"
        label.textColor = .gray400
        label.textAlignment = .left
        return label
    }()

    lazy var ssidFieldLabel: UILabel = {
        let label = UILabel()
        label.text = "Sample Text" // 텍스트 설정
        label.font = .tgPasswordS
        label.textColor = .gray300
        label.textAlignment = .left

        // 스타일 적용
        label.addLabelSpacing(fontStyle: .tgPasswordS)
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
        label.font = .tg12
        label.addLabelSpacing(fontStyle: .tg12)
        label.text = "비밀번호"
        label.textColor = .gray400
        label.textAlignment = .left
        return label
    }()

    lazy var pwFieldLabel: UILabel = {
        let label = UILabel()
        label.text = "Sample Text" // 텍스트 설정
        label.font = .tgPasswordS
        label.textColor = .gray300
        label.textAlignment = .left

        // 스타일 적용
        label.addLabelSpacing(fontStyle: .tgPasswordS)
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
        button.titleLabel?.font = .tg14
        button.titleLabel?.addLabelSpacing(fontStyle: .tg14)
        button.setTitle("복사하기", for: .normal)
        button.setTitleColor(.green200, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.green200.cgColor
        return button
    }()

    lazy var infoFirstLabel: UILabel = {
        let label = UILabel()
        label.font = .tg16
        label.addLabelSpacing(fontStyle: .tg16)
        label.numberOfLines = 0
        label.textColor = .gray400
        label.textAlignment = .center
        label.text = "WiFi 비밀번호를 복사해,"
        return label
    }()

    lazy var infoSecondLabel: UILabel = {
        let label = UILabel()
        label.font = .tg16
        label.addLabelSpacing(fontStyle: .tg16)
        label.numberOfLines = 0
        label.textColor = .gray400
        label.textAlignment = .center

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
        button.titleLabel?.font = .tg16
        button.titleLabel?.addLabelSpacing(fontStyle: .tg16)
        button.setImage(UIImage(named: "BackIcon"), for: .normal)
        button.setTitleColor(.primary200, for: .normal)
        button.backgroundColor = .clear

        button.layer.cornerRadius = 14
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.primary200.cgColor
        return button
    }()

    lazy var settingButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .tg16
        button.titleLabel?.addLabelSpacing(fontStyle: .tg16)
        button.setTitle("아이폰 설정으로 가기", for: .normal)
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
        let screenHeight = UIScreen.main.bounds.height // 화면 높이
        let screenWidth = UIScreen.main.bounds.width  // 화면 너비

        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        cameraButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(68/852 * screenHeight)
            $0.trailing.equalToSuperview().inset(24/393 * screenWidth)
            $0.width.equalTo(32/393 * screenWidth)
            $0.height.equalTo(32/852 * screenHeight)
        }

        titleStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(116/852 * screenHeight)
            $0.leading.trailing.equalToSuperview().inset(24/393 * screenWidth)
            $0.height.equalTo(59/852 * screenHeight)
        }

        memoView.snp.makeConstraints {
            $0.top.equalTo(titleStackView.snp.bottom).offset(50/852 * screenHeight)
            $0.leading.trailing.equalToSuperview().inset(24/393 * screenWidth)
            $0.height.equalTo(221/852 * screenHeight)
        }

        infoIcon.snp.makeConstraints {
            $0.top.equalToSuperview().inset(14/852 * screenHeight)
            $0.trailing.equalToSuperview().inset(16/393 * screenWidth)
            $0.width.equalTo(16/393 * screenWidth)
            $0.height.equalTo(16/852 * screenHeight)
        }

        memoText.snp.makeConstraints {
            $0.top.equalToSuperview().inset(32/852 * screenHeight)
            $0.leading.trailing.equalToSuperview().inset(16/393 * screenWidth)
            $0.height.equalTo(26/852 * screenHeight)
            $0.width.equalTo(81/393 * screenWidth)
        }

        ssidStackView.snp.makeConstraints{
            $0.top.equalTo(memoText.snp.bottom).offset(16/852 * screenHeight)
            $0.leading.trailing.equalToSuperview().inset(16/393 * screenWidth)
            $0.height.equalTo(48/852 * screenHeight)
        }

        pwStackView.snp.makeConstraints {
            $0.top.equalTo(ssidStackView.snp.bottom).offset(20/852 * screenHeight)
            $0.leading.equalToSuperview().inset(16/393 * screenWidth)
            $0.height.equalTo(48/852 * screenHeight)
            $0.width.equalTo(220/393 * screenWidth)
        }

        copyButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16/393 * screenWidth)
            $0.bottom.equalToSuperview().inset(27/852 * screenHeight)
            $0.width.equalTo(84/393 * screenWidth)
            $0.height.equalTo(38/852 * screenHeight)
        }

        infoStackView.snp.makeConstraints {
            $0.top.equalTo(memoView.snp.bottom).offset(177/852 * screenHeight)
            $0.leading.trailing.equalToSuperview().inset(24/393 * screenWidth)
            $0.height.equalTo(52/852 * screenHeight)
            $0.width.equalTo(320/393 * screenWidth)
        }

        btnStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24/393 * screenWidth)
            $0.bottom.equalToSuperview().offset(-83/852 * screenHeight)
            $0.height.equalTo(52/852 * screenHeight)
        }

        backButton.snp.makeConstraints {
            $0.width.equalTo(99/393 * screenWidth)
        }

        settingButton.snp.makeConstraints {
            $0.width.equalTo(236/393 * screenWidth)
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
