//
//  OnboardingCoordinator.swift
//  Wasap
//
//  Created by chongin on 11/16/24.
//

import UIKit

public class OnboardingCoordinator: NavigationCoordinator {
    public var parentCoordinator: (any Coordinator)? = nil
    public var childCoordinators: [any Coordinator] = []
    public var navigationController: UINavigationController

    let wifiAutoConnectDIContainer: WifiAutoConnectDIContainer

    public init(navigationController: UINavigationController, wifiAutoConnectDIContainer: WifiAutoConnectDIContainer) {
        self.navigationController = navigationController
        self.wifiAutoConnectDIContainer = wifiAutoConnectDIContainer
    }

    public enum Flow {
        case camera
    }

    public func start() {
        // TODO: DI로 생성하기
        let viewModel = OnboardingViewModel(coordinatorController: self)
        let viewController = OnboardingViewController(viewModel: viewModel)

        navigationController.pushViewController(viewController, animated: true)
    }

    public func finish() {
        self.navigationController.popViewController(animated: true)
    }
}

extension OnboardingCoordinator: OnboardingCoordinatorController {
    public func performTransition(to flow: Flow) {

    }
}
