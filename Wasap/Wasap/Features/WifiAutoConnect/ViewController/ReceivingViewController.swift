//
//  ReceivingViewController.swift
//  Wasap
//
//  Created by Chang Jonghyeon on 11/10/24.
//

import RxSwift
import RxCocoa
import UIKit

public class ReceivingViewController: RxBaseViewController<ReceivingViewModel> {
    private let receivingView = ReceivingView()

    public override func viewDidLoad() {
        super.viewDidLoad()
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

        // 뷰모델 -> 뷰

    }
}
