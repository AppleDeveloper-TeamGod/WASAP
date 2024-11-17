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

    override public init(viewModel: OnboardingViewModel) {
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

        onboardingView.setScrollViewContents()
    }

    private func bind(_ viewModel: OnboardingViewModel) {

    }
}

extension OnboardingViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / view.frame.width)
        onboardingView.pageControl.currentPage = Int(pageIndex)
    }
}
