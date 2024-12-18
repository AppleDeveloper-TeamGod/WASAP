//
//  TipViewController.swift
//  Wasap
//
//  Created by chongin on 11/19/24.
//

import UIKit
import RxSwift

enum TipDimensions {
    static let contentWidth = UIScreen.main.bounds.width * 0.9
    static let contentHeight = UIScreen.main.bounds.height * 0.75 * 0.55
}

public class TipViewController: RxBaseViewController<TipViewModel> {
    private let tipView = TipView()
    private let tipPages: [UIView.Type]

    override public init(viewModel: TipViewModel) {
        self.tipPages = TipViewModel.tipPages
        super.init(viewModel: viewModel)
        bind(viewModel)

        tipView.backgroundColor = .gray50
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        Log.print("Notification sent: viewDidDismiss")
        NotificationCenter.default.post(name: .viewDidDismiss, object: nil)
    }

    public override func loadView() {
        self.view = tipView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        setScrollViewContents(self.tipPages)

        Log.print("Notification sent: viewDidPresent")
        NotificationCenter.default.post(name: .viewDidPresent, object: nil)
    }

    private func bind(_ viewModel: TipViewModel) {
        self.tipView.xbutton.rx.tap
            .bind(to: viewModel.closeButtonDidTap)
            .disposed(by: disposeBag)

        self.tipView.bottomCloseButton.rx.tap
            .bind(to: viewModel.closeButtonDidTap)
            .disposed(by: disposeBag)

        self.tipView.scrollView.rx.contentOffset
            .bind(to: viewModel.currentScrollViewOffset)
            .disposed(by: disposeBag)

        self.tipView.pageControl.rx.controlEvent(.valueChanged)
            .compactMap { [weak self] _ in
                self?.tipView.pageControl.currentPage
            }
            .bind(to: viewModel.currentPageControlInput)
            .disposed(by: disposeBag)

        viewModel.changeViaPageControl
            .drive { [weak self] pageNumber in
                self?.tipView.scrollView.contentOffset.x = CGFloat(pageNumber) * TipDimensions.contentWidth
            }
            .disposed(by: disposeBag)
    }

    private func setScrollViewContents(_ tipPages: [UIView.Type]) {
        let contentWidth = TipDimensions.contentWidth
        let contentHeight = TipDimensions.contentHeight

        self.tipView.pageControl.numberOfPages = tipPages.count

        self.tipView.scrollView.contentSize = CGSize(width: contentWidth * CGFloat(tipPages.count), height: contentHeight)
        tipPages.enumerated().forEach { index, page in
            let rect = CGRect(x: contentWidth * CGFloat(index), y: 0, width: contentWidth, height: contentHeight)
            let view = page.init(frame: rect)
            self.tipView.scrollView.addSubview(view)
        }
    }
}
