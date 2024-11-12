//
//  ShareQRViewController.swift
//  Wasap
//
//  Created by Chang Jonghyeon on 11/11/24.
//

import RxSwift
import RxCocoa
import UIKit

public class SharingQRViewController: RxBaseViewController<SharingQRViewModel> {
    private let sharingQRView = SharingQRView()

    public override func viewDidLoad() {
        super.viewDidLoad()
    }

    public override func loadView() {
        super.loadView()
        self.view = sharingQRView
    }

    override init(viewModel: SharingQRViewModel) {
        super.init(viewModel: viewModel)
        bind(viewModel)
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func bind(_ viewModel: SharingQRViewModel) {
        // 뷰 -> 뷰모델
        sharingQRView.xButton.rx.tap
            .bind(to: viewModel.xButtonTapped)
            .disposed(by: disposeBag)

        sharingQRView.closeButton.rx.tap
            .bind(to: viewModel.closeButtonTapped)
            .disposed(by: disposeBag)

        // 뷰모델 -> 뷰
        viewModel.qrCodeImage
            .drive { [weak self] image in
                self?.sharingQRView.qrCodeView.image = image
            }
            .disposed(by: disposeBag)
    }
}
