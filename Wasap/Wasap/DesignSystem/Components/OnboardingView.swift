//
//  OnboardingView.swift
//  Wasap
//
//  Created by chongin on 11/9/24.
//

import UIKit
import SnapKit
import Lottie

final class OnboardingView: BaseView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @MainActor required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Top Area
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "AppIconLabel"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    public lazy var skipButton: UIButton = {
        let button = UIButton()
        let attribute = [NSAttributedString.Key.font: UIFont.tg16, .foregroundColor: UIColor.gray400, .baselineOffset: 2]
        let attributedTitle = NSAttributedString(string: "Skip".localized(), attributes: attribute)
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }()

    public lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        scrollView.backgroundColor = .clear
        return scrollView
    }()

    // MARK: - Bottom Area
    public lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = .textPrimaryHigh
        pageControl.pageIndicatorTintColor = .gray300
        return pageControl
    }()

    public lazy var nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("다음".localized(), for: .normal)
        button.setTitleColor(.gray450, for: .normal)
        button.backgroundColor = .green200
        button.layer.cornerRadius = 25
        return button
    }()
}

/// Scroll할 때 PageControl도 따라오도록 설정
extension OnboardingView: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / self.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }
}

extension OnboardingView {
    func setViewHierarchy() {
        self.addSubViews(logoImageView, skipButton, scrollView, pageControl, nextButton)

    }

    func setConstraints() {
        self.logoImageView.snp.makeConstraints {
            $0.top.leading.equalTo(safeAreaLayoutGuide).offset(16)
            $0.height.equalTo(32)
        }

        self.skipButton.snp.makeConstraints {
            $0.top.trailing.equalTo(safeAreaLayoutGuide).inset(16)
            $0.width.equalTo(38)
        }

        self.scrollView.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(84)
            $0.leading.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.55)
            $0.width.equalToSuperview()
        }

        self.pageControl.snp.makeConstraints {
            $0.bottom.equalTo(self.nextButton.snp.top).offset(-16)
            $0.centerX.equalToSuperview()
        }

        self.nextButton.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-28)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.9)
            $0.height.equalTo(52)
        }
    }
}

final class OnboardingPage1: BaseView {
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Onboarding1"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "누구나 쉽게, 사진으로 연결.".localized()
        label.font = .tg24
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Wi-Fi 안내문을 실시간 인식하여\n네트워크 연결!".localized()
        label.font = .tg16
        label.addLabelSpacing(fontStyle: .tg16)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .gray450
        return label
    }()

    func setViewHierarchy() {
        self.addSubViews(imageView, titleLabel, descriptionLabel)
    }

    func setConstraints() {
        self.imageView.snp.makeConstraints {
            $0.width.equalTo(265)
            $0.height.equalTo(self.imageView.snp.width)
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview()
        }

        self.titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.imageView.snp.bottom).offset(56)
            $0.centerX.equalToSuperview()
        }

        self.descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
    }
}


final class OnboardingPage2: BaseView {
    private lazy var lottieAnimation: LottieAnimationView = {
        let animation = LottieAnimationView(name: "OB2page")
        animation.loopMode = .loop
        animation.play()
        return animation
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "같이 쓰는 것도, 쉽게.".localized()
        label.font = .tg24
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "wasap을 통해 Wi-Fi를\n공유받아 바로 연결!".localized()
        label.font = .tg16
        label.addLabelSpacing(fontStyle: .tg16)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .gray450
        return label
    }()

    func setViewHierarchy() {
        self.addSubViews(lottieAnimation, titleLabel, descriptionLabel)
    }

    func setConstraints() {
        self.lottieAnimation.snp.makeConstraints {
            $0.width.equalTo(265)
            $0.height.equalTo(self.lottieAnimation.snp.width)
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview()
        }

        self.titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.lottieAnimation.snp.bottom).offset(56)
            $0.centerX.equalToSuperview()
        }

        self.descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
    }
}
