//
//  SharingQRViewModel.swift
//  Wasap
//
//  Created by Chang Jonghyeon on 11/11/24.
//

import RxSwift
import RxCocoa
import UIKit

public class SharingQRViewModel: BaseViewModel {
    // MARK: - Coordinator
    private weak var coordinatorController: SharingQRCoordinatorController?

    // MARK: - UseCase
    private let wifiShareUseCase: WiFiShareUseCase

    // MARK: - Input
    public let xButtonTapped = PublishRelay<Void>()
    public let closeButtonTapped = PublishRelay<Void>()

    // MARK: - Output
    public var qrCodeImage: Driver<UIImage>

    public init(wifiShareUseCase: WiFiShareUseCase, coordinatorController: SharingQRCoordinatorController, ssid: String, password: String) {
        self.wifiShareUseCase = wifiShareUseCase

        let qrCodeImageRelay = BehaviorRelay<UIImage?>(value: nil)
        self.qrCodeImage = qrCodeImageRelay.asDriver(onErrorJustReturn: nil).compactMap { $0 }

        self.coordinatorController = coordinatorController
        super.init()

        viewDidLoad
            .withUnretained(self)
            .flatMapLatest { owner, _ in
                wifiShareUseCase.generateQRCode(ssid: ssid, password: password)
            }
            .subscribe { qrImage in
                Log.print("QR code generated successfully.")
                qrCodeImageRelay.accept(qrImage)
            } onError: { error in
                Log.error("\(error.localizedDescription)")
            }
            .disposed(by: disposeBag)

        self.xButtonTapped
            .withUnretained(self)
            .subscribe { owner, _ in
                owner.coordinatorController?.performFinish(to: .pop)
            }
            .disposed(by: disposeBag)

        self.closeButtonTapped
            .withUnretained(self)
            .subscribe { owner, _ in
                owner.coordinatorController?.performFinish(to: .pop)
            }
            .disposed(by: disposeBag)
    }
}

