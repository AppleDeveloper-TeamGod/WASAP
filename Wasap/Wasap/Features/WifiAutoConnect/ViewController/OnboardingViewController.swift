//
//  OnboardingViewController.swift
//  Wasap
//
//  Created by chongin on 11/16/24.
//

import UIKit
import RxSwift

enum OnboardingDimensions {
    static let contentWidth = UIScreen.main.bounds.width
    static let contentHeight = UIScreen.main.bounds.height * 0.55
}

public class OnboardingViewController: RxBaseViewController<OnboardingViewModel> {
    private let onboardingView = OnboardingView()
    private let onboardingPages: [UIView.Type]

    override public init(viewModel: OnboardingViewModel) {
        self.onboardingPages = OnboardingViewModel.onboardingPages
        super.init(viewModel: viewModel)
        bind(viewModel)
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func loadView() {
        self.view = onboardingView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        setScrollViewContents(self.onboardingPages)
    }

    private func bind(_ viewModel: OnboardingViewModel) {
        self.onboardingView.skipButton.rx.tap
            .bind(to: viewModel.skipButtonDidTap)
            .disposed(by: disposeBag)

        self.onboardingView.nextButton.rx.tap
            .bind(to: viewModel.nextButtonDidTap)
            .disposed(by: disposeBag)

        self.onboardingView.scrollView.rx.contentOffset
            .bind(to: viewModel.currentScrollViewOffset)
            .disposed(by: disposeBag)

        self.onboardingView.pageControl.rx.controlEvent(.valueChanged)
            .compactMap { [weak self] _ in
                self?.onboardingView.pageControl.currentPage
            }
            .bind(to: viewModel.currentPageControlInput)
            .disposed(by: disposeBag)

        viewModel.currentPageOutput
            .drive { [weak self] pageNumber in
                if pageNumber == OnboardingViewModel.onboardingPages.count - 1 {
                    self?.onboardingView.nextButton.setTitle("시작하기".localized(), for: .normal)
                } else {
                    self?.onboardingView.nextButton.setTitle("다음".localized(), for: .normal)
                }
            }
            .disposed(by: disposeBag)

        viewModel.changeViaPageControl
            .drive { [weak self] pageNumber in
                self?.onboardingView.scrollView.contentOffset.x = CGFloat(pageNumber) * OnboardingDimensions.contentWidth
            }
            .disposed(by: disposeBag)
    }

    private func setScrollViewContents(_ onboardingPages: [UIView.Type]) {
        let contentWidth = OnboardingDimensions.contentWidth
        let contentHeight = OnboardingDimensions.contentHeight

        self.onboardingView.pageControl.numberOfPages = onboardingPages.count

        self.onboardingView.scrollView.contentSize = CGSize(width: contentWidth * CGFloat(onboardingPages.count), height: contentHeight)
        onboardingPages.enumerated().forEach { index, page in
            let rect = CGRect(x: contentWidth * CGFloat(index), y: 0, width: contentWidth, height: contentHeight)
            let view = page.init(frame: rect)
            self.onboardingView.scrollView.addSubview(view)
        }
    }
}
