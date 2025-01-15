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

    public enum Flow {}

    public func start() {
        let navigationController = UINavigationController()
        navigationController.setNavigationBarHidden(true, animated: false)
        if let isFirstLaunch: Bool = UserDefaultsManager.shared.get(.isFirstLaunch), isFirstLaunch == false {
            let cameraCoordinator = CameraCoordinator(navigationController: navigationController, wifiAutoConnectDIContainer: appDIContainer.makeWifiAutoConnectDIContainer())
            start(childCoordinator: cameraCoordinator)

        } else {
            UserDefaultsManager.shared.set(value: false, forKey: .isFirstLaunch)
            let onboardingCoordinator = OnboardingCoordinator(navigationController: navigationController, wifiAutoConnectDIContainer: appDIContainer.makeWifiAutoConnectDIContainer())
            start(childCoordinator: onboardingCoordinator)
        }

        window?.rootViewController = navigationController
        Toaster.shared.connect(to: navigationController)
        window?.makeKeyAndVisible()
    }

    public func finish() {
        fatalError("You cannot finish Root Coordinator")
    }
}
