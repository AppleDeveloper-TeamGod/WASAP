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

    lazy var cameraBtn : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "GoCameraButton"), for: .normal)
        return button
    }()

    lazy var titleLabel1: UILabel = {
        let label = UILabel()
        label.text = "인식된 정보를 확인하고,"
        label.textColor = .gray200
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 21)
        return label
    }()

    lazy var titleLabel2: UILabel = {
        let label = UILabel()
        label.text = "설정에서 시도하세요."
        label.textColor = .green300
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 21)
        return label
    }()

    lazy var titleStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel1, titleLabel2])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 3
        return stackView
    }()
    
    lazy var memoView : UIView = {
        let view = UIView()
        view.backgroundColor = .neutral450
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()

    lazy var ssidLabel: UILabel = {
        let label = UILabel()
        label.text = "와이파이 ID"
        label.textColor = .white
        label.font = FontStyle.subTitle.font.withSize(10)
        label.addLabelSpacing(fontStyle: FontStyle.subTitle)
        label.textAlignment = .left
        return label
    }()

    lazy var ssidFieldLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.backgroundColor = UIColor.neutral450
        label.font = FontStyle.password_M.font.withSize(15)
        label.layer.cornerRadius = 13
        label.layer.masksToBounds = true
        label.textAlignment = .left
        label.text = "SSID" // 기본 텍스트 설정 (예시)
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
        label.textColor = .white
        label.font = FontStyle.subTitle.font.withSize(10)
        label.addLabelSpacing(fontStyle: FontStyle.subTitle)
        label.textAlignment = .left
        return label
    }()

    lazy var pwFieldLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.backgroundColor = .neutral450
        label.text = "비밀번호"
        label.font = FontStyle.password_M.font.withSize(15)
        label.font = .preferredFont(forTextStyle: .headline)
        label.layer.cornerRadius = 13
        label.layer.masksToBounds = true
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
        button.backgroundColor = .clear

        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.green200.cgColor
        return button
    }()

    lazy var infoIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "info_icon")
        return imageView
    }()

    lazy var infoFirstLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .white
        label.textAlignment = .left
        label.text = "WiFi 비밀번호를 복사해 두면"
        return label
    }()

    lazy var infoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [infoIcon, infoFirstLabel])
        stackView.axis = .horizontal
        stackView.spacing = 6
        return stackView
    }()

    lazy var infoSecondLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .gray100
        label.textAlignment = .left
        label.font = FontStyle.subTitle.font.withSize(16)

        let wifiID = "설정 > Wi-Fi"
        let description = "\(wifiID) "+"에서 쉽게 연결할 수 있습니다."

        // 글자 색깔 넣기
        let attributedString = NSMutableAttributedString(string: description)
        if let wifiIDRange = description.range(of: wifiID) {
            let nsRange = NSRange(wifiIDRange, in: description)
            attributedString.addAttribute(.foregroundColor, value: UIColor.primary200, range: nsRange)
        }

        label.attributedText = attributedString
        return label
    }()



    lazy var backBtn: UIButton = {
        let button = UIButton()
        button.setTitle("<", for: .normal)
        button.setTitleColor(.primary200, for: .normal)
        button.backgroundColor = .clear

        button.layer.cornerRadius = 14
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.primary200.cgColor
        return button
    }()

    lazy var settingBtn: UIButton = {
        let button = UIButton()
        button.setTitle("아이폰 설정으로 가기", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = FontStyle.button.font
        button.titleLabel?.addLabelSpacing(fontStyle: FontStyle.button)
        button.backgroundColor = .primary200

        button.layer.cornerRadius = 14
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.clear.cgColor
        return button
    }()

    lazy var btnStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [backBtn, settingBtn])
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
        backgroundView.addSubViews(cameraBtn,titleStackView,memoView,
                                   infoStackView,infoSecondLabel,btnStackView)
        memoView.addSubViews(ssidStackView,pwStackView,copyButton)
    }
    
    func setConstraints() {
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        cameraBtn.snp.makeConstraints {
            $0.top.equalToSuperview().offset(71)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.height.equalTo(26)
        }

        titleStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(116)
            $0.leading.equalToSuperview().inset(24)
            $0.height.equalTo(59)
        }

        memoView.snp.makeConstraints {
            $0.top.equalTo(titleStackView.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(152)
        }

        ssidStackView.snp.makeConstraints{
            $0.top.equalToSuperview().offset(17)
            $0.leading.trailing.equalToSuperview().inset(17)
            $0.height.equalTo(48)
        }

        pwStackView.snp.makeConstraints {
            $0.top.equalTo(ssidStackView.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(17)
            $0.height.equalTo(48)
        }

        copyButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(17)
            $0.top.equalToSuperview().offset(103)
            $0.width.equalTo(84)
            $0.height.equalTo(38)
        }

        infoIcon.snp.makeConstraints {
            $0.width.height.equalTo(16)
        }

        infoStackView.snp.makeConstraints {
            $0.top.equalTo(memoView.snp.bottom).offset(18)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        infoSecondLabel.snp.makeConstraints {
            $0.top.equalTo(infoStackView.snp.bottom).offset(1)
            $0.leading.equalToSuperview().inset(46)
        }

        btnStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.top.equalTo(infoSecondLabel.snp.bottom).offset(297)
            $0.height.equalTo(52)
        }

        backBtn.snp.makeConstraints {
            $0.width.equalTo(99)
        }

        settingBtn.snp.makeConstraints {
            $0.width.equalTo(236)
        }
    }
}
