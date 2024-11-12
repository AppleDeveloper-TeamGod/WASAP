//
//  ReceivingViewModel.swift
//  Wasap
//
//  Created by Chang Jonghyeon on 11/10/24.
//

import RxSwift
import RxCocoa
import UIKit

public class ReceivingViewModel: BaseViewModel {
    // MARK: - Coordinator
    private weak var coordinatorController: ReceivingCoordinatorController?

    // MARK: - Input
    public let connectButtonTapped = PublishRelay<Void>()
    public let xButtonTapped = PublishRelay<Void>()

    // MARK: - Output
    public let ssidDriver: Driver<String>

    public init(coordinatorController: ReceivingCoordinatorController, ssid: String, password: String) {

        let ssidRelay = BehaviorRelay<String>(value: "‘\(ssid)’")
        self.ssidDriver = ssidRelay.asDriver()

        self.coordinatorController = coordinatorController
        super.init()

        xButtonTapped
            .withUnretained(self)
            .subscribe { owner, _ in
                owner.coordinatorController?.performFinish(to: .pop)
            }
            .disposed(by: disposeBag)

        connectButtonTapped
            .withUnretained(self)
            .subscribe { owner, _ in
                owner.coordinatorController?.performTransition(to: .connecting(ssid: ssid, password: password))
            }
            .disposed(by: disposeBag)

    }
}
