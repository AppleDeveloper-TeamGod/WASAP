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

        self.navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.pushViewController(viewController, animated: true)
    }

    public func finish() {
        DispatchQueue.main.async {
            self.navigationController.popViewController(animated: false)
        }
    }
}

extension OnboardingCoordinator: OnboardingCoordinatorController {
    public func performTransition(to flow: Flow) {
        switch flow {
        case .camera:
            DispatchQueue.main.async {
                let coordinator = CameraCoordinator(navigationController: self.navigationController, wifiAutoConnectDIContainer: self.wifiAutoConnectDIContainer)
                self.switch(childCoordinator: coordinator)
            }
        }
    }

    public func performStartSplash() {
        SplashController.shared.startSplash()
    }
}
