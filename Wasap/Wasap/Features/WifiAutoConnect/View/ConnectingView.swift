//
//  ConnectingView.swift
//  Wasap
//
//  Created by Chang Jonghyeon on 10/14/24.
//

import UIKit
import SnapKit
import Lottie

class ConnectingView: BaseView {
    lazy var backgroundView: UIView = {
        let view = GradientBackgroundView()
        return view
    }()
    
    lazy var quitButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "QuitButtonDefault"), for: .normal)
        button.isHidden = true
        return button
    }()
    
    lazy var doneSignIcon: UIImageView = {
        let icon = UIImageView(image: UIImage(named: "DoneIcon"))
        icon.isHidden = true
        return icon
    }()
    
    lazy var mainStatusLabel: UILabel = {
        let label = UILabel()
        label.text = "ASAP!"
        label.textColor = .neutralWhite
        label.font = FontStyle.title.font
        label.addLabelSpacing(fontStyle: FontStyle.title)
        return label
    }()
    
    lazy var subStatusLabel: UILabel = {
        let label = UILabel()
        label.textColor = .neutralWhite
        label.font = FontStyle.subTitle.font
        label.addLabelSpacing(fontStyle: FontStyle.subTitle)
        label.textAlignment = .center
        return label
    }()
    
    lazy var loadingAnimation: LottieAnimationView = {
        let animation = LottieAnimationView(name: "processing")
        animation.loopMode = .loop
        animation.play()
        return animation
    }()
    
    func setViewHierarchy() {
        self.addSubview(backgroundView)
        self.addSubViews(loadingAnimation, mainStatusLabel, subStatusLabel, doneSignIcon, quitButton)
    }
    
    func setConstraints() {
        backgroundView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        quitButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(71)
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.equalTo(26)
            $0.height.equalTo(26)
        }

        mainStatusLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(359)
            $0.width.equalTo(91)
            $0.height.equalTo(36)
        }

        subStatusLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(mainStatusLabel.snp.bottom).offset(6)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(30)
        }

        doneSignIcon.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(mainStatusLabel.snp.top).offset(-6)
        }
        
        loadingAnimation.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}
