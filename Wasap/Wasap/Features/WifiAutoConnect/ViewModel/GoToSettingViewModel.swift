//
//  GoToSettingViewModel.swift
//  Wasap
//
//  Created by 김상준 on 10/15/24.
//

import Foundation
import RxSwift
import UIKit
import RxCocoa

public class GoToSettingViewModel: BaseViewModel {

    // MARK: - Coordinator
    private weak var coordinatorController: GoToSettingCoordinatorController?

    // MARK: - Input
    public let setButtonTapped = PublishRelay<Void>()
    public let cameraButtonTapped = PublishRelay<Void>()
    public let backButtonTapped = PublishRelay<Void>()
    public let copyButtonTapped = PublishRelay<Void>()

    // MARK: - Output
    public let ssidDriver: Driver<String>
    public let passwordDriver: Driver<String>
    public let imageDriver: Driver<UIImage>

    public init(goToSettingUseCase: GoToSettingUseCase,
                coordinatorController: GoToSettingCoordinatorController,
                imageData: UIImage, ssid : String, password: String) {

        self.coordinatorController = coordinatorController

        let imageRelay = BehaviorRelay<UIImage>(value: imageData)
        self.imageDriver = imageRelay.asDriver()

        let ssidRelay = BehaviorRelay<String>(value: ssid)
        self.ssidDriver = ssidRelay.asDriver()

        let passwordRelay = BehaviorRelay<String>(value: password)
        self.passwordDriver = passwordRelay.asDriver()

        super.init()

        cameraButtonTapped
            .subscribe(onNext: { [weak self] in
                self?.coordinatorController?.performFinish(to: .popToRoot)
            })
            .disposed(by: disposeBag)

        backButtonTapped
            .subscribe(onNext: { [weak self] in
                self?.coordinatorController?.performPop()
            })
            .disposed(by: disposeBag)


        setButtonTapped
            .subscribe(onNext: {
                goToSettingUseCase.openSettings()
            })
            .disposed(by: disposeBag)

        copyButtonTapped
            .subscribe(onNext: {
                goToSettingUseCase.copyPassword(pw: password)
                Toaster.shared.toast("복사 되었습니다.", delay: 2.0,top: 320)
            })
            .disposed(by: disposeBag)

    }
}


