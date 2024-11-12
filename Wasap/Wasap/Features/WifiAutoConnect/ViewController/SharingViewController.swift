//
//  SharingViewController.swift
//  Wasap
//
//  Created by Chang Jonghyeon on 11/9/24.
//

import RxSwift
import RxCocoa
import UIKit

public class SharingViewController: RxBaseViewController<SharingViewModel> {
    private let sharingView = SharingView()

    public override func viewDidLoad() {
        super.viewDidLoad()
    }

    public override func loadView() {
        super.loadView()
        self.view = sharingView
    }

    override init(viewModel: SharingViewModel) {
        super.init(viewModel: viewModel)
        bind(viewModel)
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func bind(_ viewModel: SharingViewModel) {
        // 뷰 -> 뷰모델
        sharingView.backButton.rx.tap
            .bind(to: viewModel.backButtonTapped)
            .disposed(by: disposeBag)

        sharingView.stopShareButton.rx.tap
            .bind(to: viewModel.stopShareButtonTapped)
            .disposed(by: disposeBag)

        sharingView.shareQRButton.rx.tap
            .bind(to: viewModel.shareQRButtonTapped)
            .disposed(by: disposeBag)

        // 뷰모델 -> 뷰
        viewModel.connectedPeerCount
            .drive { [weak self] count in
                self?.sharingView.peerCountLabel.text = "\(count)"
            }
            .disposed(by: disposeBag)
    }
}
