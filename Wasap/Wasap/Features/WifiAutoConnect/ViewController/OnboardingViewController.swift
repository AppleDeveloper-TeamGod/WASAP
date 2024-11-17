//
//  OnboardingViewController.swift
//  Wasap
//
//  Created by chongin on 11/16/24.
//

import UIKit
import RxSwift

public class OnboardingViewController: RxBaseViewController<OnboardingViewModel> {
    private let onboardingView = OnboardingView()
    private let onboardingPages: [UIView.Type]
    private static let contentWidth = UIScreen.main.bounds.width
    private static let contentHeight = UIScreen.main.bounds.height * 0.55

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
            .withUnretained(self)
            .map { owner, offset in
                let pageIndex = round(offset.x / Self.contentWidth)
                return Int(pageIndex)
            }
            .bind(to: viewModel.currentPageInput)
            .disposed(by: disposeBag)

        self.onboardingView.pageControl.rx.controlEvent(.valueChanged)
            .compactMap { [weak self] _ in
                self?.onboardingView.pageControl.currentPage
            }
            .bind(to: viewModel.currentPageInput)
            .disposed(by: disposeBag)

        viewModel.currentPageOutput
            .drive { [weak self] pageNumber in
                self?.onboardingView.pageControl.currentPage = pageNumber
                self?.onboardingView.scrollView.contentOffset.x = CGFloat(pageNumber) * Self.contentWidth
            }
            .disposed(by: disposeBag)
    }

    private func setScrollViewContents(_ onboardingPages: [UIView.Type]) {
        let contentWidth = Self.contentWidth
        let contentHeight = Self.contentHeight

        self.onboardingView.pageControl.numberOfPages = onboardingPages.count

        self.onboardingView.scrollView.contentSize = CGSize(width: contentWidth * CGFloat(onboardingPages.count), height: contentHeight)
        onboardingPages.enumerated().forEach { index, page in
            let rect = CGRect(x: contentWidth * CGFloat(index), y: 0, width: contentWidth, height: contentHeight)
            let view = page.init(frame: rect)
            self.onboardingView.scrollView.addSubview(view)
        }
    }
}
