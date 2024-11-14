//
//  GotoSettingCoordinator.swift
//  Wasap
//
//  Created by 김상준 on 10/15/24.
//

import Foundation
import UIKit

public class GoToSettingCoordinator: NavigationCoordinator {
    public var parentCoordinator: (any Coordinator)? = nil
    public var childCoordinators: [any Coordinator] = []
    public let navigationController: UINavigationController
    private let wifiAutoConnectDIContainer: WifiAutoConnectDIContainer

    let imageData : UIImage
    let ssid : String
    let password : String

    public init(navigationController: UINavigationController,
                wifiAutoConnectDIContainer: WifiAutoConnectDIContainer,
                imageData: UIImage, ssid: String, password: String) {
        self.navigationController = navigationController
        self.wifiAutoConnectDIContainer = wifiAutoConnectDIContainer
        self.imageData = imageData
        self.ssid = ssid
        self.password = password
    }

    public enum FinishFlow {
        case popToRoot
        case popToRetry
    }

    public func start() {
        let repository = wifiAutoConnectDIContainer.makeGoToSettingRepository()
        let usecase = wifiAutoConnectDIContainer.makeGoToSettingUseCase(repository)
        let viewModel = wifiAutoConnectDIContainer.makeGoToSettingViewModel(goToSettingUseCase: usecase, coordinatorcontroller: self, imageData: imageData, ssid: ssid, password: password)
        let viewController = wifiAutoConnectDIContainer.makeGoToSettingViewController(viewModel)

        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }

    public func finish() {
        self.navigationController.popViewController(animated: true)
    }
}

extension GoToSettingCoordinator: GoToSettingCoordinatorController {

    public func performFinish(to flow: FinishFlow) {
        switch flow {
        case .popToRoot:
            finishUntil(CameraCoordinator.self)
        case .popToRetry:
            finishUntil(WifiReConnectCoordinator.self)
        }
    }
}

