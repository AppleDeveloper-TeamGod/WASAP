//
//  RootCoordinator.swift
//  Wasap
//
//  Created by chongin on 10/3/24.
//

import UIKit

public class RootCoordinator: Coordinator {
    public var parentCoordinator: (any Coordinator)? = nil

    public var childCoordinators: [Coordinator] = []
    let window: UIWindow?
    let appDIContainer: AppDIContainer

    init(window: UIWindow?, appDIContainer: AppDIContainer) {
        self.window = window
        self.appDIContainer = appDIContainer
    }

    public enum Flow {

    }

    public func start() {
        let navigationController = UINavigationController()
        let onboardingCoordinator = OnboardingCoordinator(navigationController: navigationController, wifiAutoConnectDIContainer: appDIContainer.makeWifiAutoConnectDIContainer())
//        let cameraCoordinator = CameraCoordinator(navigationController: UINavigationController(), wifiAutoConnectDIContainer: appDIContainer.makeWifiAutoConnectDIContainer())
        start(childCoordinator: onboardingCoordinator)
        window?.rootViewController = navigationController
        Toaster.shared.connect(to: navigationController)
        window?.makeKeyAndVisible()
    }

    public func finish() {
        fatalError("You cannot finish Root Coordinator")
    }
}
