//
//  GotoSettingCoordinator.swift
//  Wasap
//
//  Created by 김상준 on 10/15/24.
//

import Foundation
import UIKit

public class GoToSettingCoordinator: NavigationCoordinator {
    public weak var parentCoordinator: (any Coordinator)? = nil
    public var childCoordinators: [any Coordinator] = []
    public let navigationController: UINavigationController
    private let wifiAutoConnectDIContainer: WifiAutoConnectDIContainer

    let image: UIImage
    let ssid: String
    let password : String

    public init(navigationController: UINavigationController,
                wifiAutoConnectDIContainer: WifiAutoConnectDIContainer,
                image: UIImage, ssid: String, password: String) {
        self.navigationController = navigationController
        self.wifiAutoConnectDIContainer = wifiAutoConnectDIContainer
        self.image = image
        self.ssid = ssid
        self.password = password
    }

    deinit {
        Log.debug("GoToSettingCoordinator deinit")
    }

    public enum FinishFlow {
        case popToRoot
    }

    public func start() {
        let repository = wifiAutoConnectDIContainer.makeGoToSettingRepository()
        let usecase = wifiAutoConnectDIContainer.makeGoToSettingUseCase(repository)
        let viewModel = wifiAutoConnectDIContainer.makeGoToSettingViewModel(goToSettingUseCase: usecase, coordinatorcontroller: self, imageData: image, ssid: ssid, password: password)
        let viewController = wifiAutoConnectDIContainer.makeGoToSettingViewController(viewModel)

        self.navigationController.setNavigationBarHidden(true, animated: false)
        var viewControllers = self.navigationController.viewControllers
        _ = viewControllers.popLast()
        viewControllers.append(viewController)
        self.navigationController.setViewControllers(viewControllers, animated: true)
    }
    
    public func finish() {
        self.navigationController.popViewController(animated: true)
    }
}

extension GoToSettingCoordinator: GoToSettingCoordinatorController {
    public func performPop() {
        finish()
    }

    public func performFinish(to flow: FinishFlow) {
        switch flow {
        case .popToRoot:
            finishUntil(CameraCoordinator.self)
        }
    }
}

