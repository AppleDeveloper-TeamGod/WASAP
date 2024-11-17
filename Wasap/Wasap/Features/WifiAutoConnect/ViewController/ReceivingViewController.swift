//
//  ReceivingViewController.swift
//  Wasap
//
//  Created by Chang Jonghyeon on 11/10/24.
//

import RxSwift
import RxCocoa
import UIKit

public class ReceivingViewController: RxBaseViewController<ReceivingViewModel>, UIAdaptivePresentationControllerDelegate {
    private let receivingView = ReceivingView()

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.presentationController?.delegate = self

        Log.print("Notification sent: receivingViewDidPresent")
        NotificationCenter.default.post(name: .receivingViewDidPresent, object: nil)
    }

    public override func loadView() {
        super.loadView()
        self.view = receivingView
    }

    override init(viewModel: ReceivingViewModel) {
        super.init(viewModel: viewModel)
        bind(viewModel)
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func bind(_ viewModel: ReceivingViewModel) {
        // 뷰 -> 뷰모델
        receivingView.xButton.rx.tap
            .bind(to: viewModel.xButtonTapped)
            .disposed(by: disposeBag)

        receivingView.connectButton.rx.tap
            .bind(to: viewModel.connectButtonTapped)
            .disposed(by: disposeBag)

        // 뷰모델 -> 뷰
        viewModel.ssidDriver
            .drive(receivingView.ssidLabel.rx.text)
            .disposed(by: disposeBag)
    }

    deinit {
        Log.print("Notification sent: receivingViewDidDismiss")
        NotificationCenter.default.post(name: .receivingViewDidDismiss, object: nil)
    }
}

extension Notification.Name {
    static let receivingViewDidPresent = Notification.Name("receivingViewDidPresent")
    static let receivingViewDidDismiss = Notification.Name("receivingViewDidDismiss")
}
