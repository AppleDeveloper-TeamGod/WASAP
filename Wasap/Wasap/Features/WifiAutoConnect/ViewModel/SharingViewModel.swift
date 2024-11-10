//
//  SharingViewModel.swift
//  Wasap
//
//  Created by Chang Jonghyeon on 11/9/24.
//

import RxSwift
import RxCocoa
import UIKit

public class SharingViewModel: BaseViewModel {
    // MARK: - Coordinator
    private weak var coordinatorController: SharingCoordinatorController?

    // MARK: - UseCase
    private let wifiShareUseCase: WiFiShareUseCase

    // MARK: - Input
    // MARK: - Output
    public var connectedPeerCount: Driver<Int>

    public init(wifiShareUseCase: WiFiShareUseCase, coordinatorController: SharingCoordinatorController, ssid: String, password: String) {
        self.wifiShareUseCase = wifiShareUseCase

        let connectedPeerCountRelay = BehaviorRelay<Int>(value: 0)
        self.connectedPeerCount = connectedPeerCountRelay.asDriver()

        var isAdvertising = BehaviorRelay<Bool>(value: false)

        self.coordinatorController = coordinatorController
        super.init()

        viewDidLoad
            .withUnretained(self)
            .flatMapLatest { owner, _ in
                wifiShareUseCase.startAdvertising(ssid: ssid, password: password)
            }
            .subscribe {
                Log.debug("start Advertising")
                isAdvertising.accept(true)
            } onError: { error in
                Log.error("\(error.localizedDescription)")
            }
            .disposed(by: disposeBag)

        isAdvertising
            .withUnretained(self)
            .flatMapLatest { owner, _ in
                owner.wifiShareUseCase.getConnectedPeerCount()
            }
            .subscribe {
                connectedPeerCountRelay.accept($0)
            }
            .disposed(by: disposeBag)
    }
}
