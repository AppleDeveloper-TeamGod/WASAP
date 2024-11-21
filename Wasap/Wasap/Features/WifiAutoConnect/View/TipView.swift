//
//  TipView.swift
//  Wasap
//
//  Created by chongin on 11/19/24.
//

import UIKit
import SnapKit
import Lottie

final class TipView: BaseView {
    public lazy var xbutton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .gray400
        button.setPreferredSymbolConfiguration(.init(pointSize: 36), forImageIn: .normal)
        return button
    }()

    public lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        return scrollView
    }()

    // MARK: - Bottom Area
    public lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = .textPrimaryHigh
        pageControl.pageIndicatorTintColor = .gray300
        return pageControl
    }()

    public lazy var bottomCloseButton: UIButton = {
        let button = UIButton()
        button.setTitle("닫기".localized(), for: .normal)
        button.backgroundColor = .green200
        button.layer.cornerRadius = 25
        return button
    }()
}

extension TipView {
    func setViewHierarchy() {
        self.addSubViews(xbutton, scrollView, pageControl, bottomCloseButton)
    }

    func setConstraints() {
        self.xbutton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(20)
            $0.width.height.equalTo(36)
        }

        self.scrollView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(88)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.9)
            $0.height.equalToSuperview().multipliedBy(0.60)
        }

        self.pageControl.snp.makeConstraints {
            $0.bottom.equalTo(self.bottomCloseButton.snp.top).offset(-16)
            $0.centerX.equalToSuperview()
        }

        self.bottomCloseButton.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(16)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.9)
            $0.height.equalTo(52)
        }
    }
}

/// Scroll할 때 PageControl도 따라오도록 설정
extension TipView: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / self.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }
}


final class TipPage1: BaseView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .gray50
    }
    
    @MainActor required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ScanTip"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "안내문 인식 팁".localized()
        label.font = .tg16
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "안내문을 중앙에 두고 초록색 박스가 나타나면 정확한 인식을 위해 잠시 기다려 주세요.".localized()
        label.font = .tg12
        label.numberOfLines = 0
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()

    func setViewHierarchy() {
        self.addSubViews(imageView, titleLabel, descriptionLabel)
    }

    func setConstraints() {
        self.imageView.snp.makeConstraints {
            $0.height.equalToSuperview().multipliedBy(0.63)
            $0.width.equalTo(self.imageView.snp.height).multipliedBy(1.4)
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview()
        }

        self.titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.imageView.snp.bottom).offset(36)
            $0.width.equalToSuperview().multipliedBy(0.9)
            $0.centerX.equalToSuperview()
        }

        self.descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(16)
            $0.width.equalToSuperview().multipliedBy(0.9)
            $0.centerX.equalToSuperview()
        }
    }
}


final class TipPage2: BaseView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .gray50
    }

    @MainActor required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var lottieAnimation: LottieAnimationView = {
        let animation = LottieAnimationView(name: "OB2page")
        animation.loopMode = .loop
        animation.play()
        return animation
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Wi-Fi 공유 받기".localized()
        label.font = .tg16
        label.textColor = .label
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "wasap을 친구가 Wi-Fi를 공유하면 첫 화면에서 '공유 알림'을 받을 수 있습니다.".localized()
        label.font = .tg12
        label.numberOfLines = 0
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()

    func setViewHierarchy() {
        self.addSubViews(lottieAnimation, titleLabel, descriptionLabel)
    }

    func setConstraints() {
        self.lottieAnimation.snp.makeConstraints {
            $0.height.equalToSuperview().multipliedBy(0.63)
            $0.width.equalTo(self.lottieAnimation.snp.height).multipliedBy(1.4)
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview()
        }

        self.titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.lottieAnimation.snp.bottom).offset(36)
            $0.width.equalToSuperview().multipliedBy(0.9)
            $0.centerX.equalToSuperview()
        }

        self.descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(16)
            $0.width.equalToSuperview().multipliedBy(0.9)
            $0.centerX.equalToSuperview()
        }
    }
}
