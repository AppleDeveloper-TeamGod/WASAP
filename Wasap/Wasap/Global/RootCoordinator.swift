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
        let cameraCoordinator = CameraCoordinator(navigationController: UINavigationController(), wifiAutoConnectDIContainer: appDIContainer.makeWifiAutoConnectDIContainer())
        start(childCoordinator: cameraCoordinator)
        window?.rootViewController = cameraCoordinator.navigationController
        Toaster.shared.connect(to: cameraCoordinator.navigationController)
        window?.makeKeyAndVisible()
    }

    public func finish() {
        fatalError("You cannot finish Root Coordinator")
    }
}
