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

        Log.print("Notification sent: viewDidPresent")
        NotificationCenter.default.post(name: .viewDidPresent, object: nil)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.post(name: .viewWillPresent, object: nil)
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: .viewWillDismiss, object: nil) // dismiss 이벤트 게시
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
        Log.print("Notification sent: viewDidDismiss")
        NotificationCenter.default.post(name: .viewDidDismiss, object: nil)
    }
}

extension Notification.Name {
    static let viewDidPresent = Notification.Name("modalViewDidPresent")
    static let viewDidDismiss = Notification.Name("modalViewDidDismiss")
    static let viewWillPresent = Notification.Name("modalViewWillPresent")
    static let viewWillDismiss = Notification.Name("modalViewWillDismiss")
}
