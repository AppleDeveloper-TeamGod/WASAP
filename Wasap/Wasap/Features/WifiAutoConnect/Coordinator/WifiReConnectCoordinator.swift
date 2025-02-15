//
//  SampleCoordinator.swift
//  Wasap
//
//  Created by 김상준 on 10/7/24.
//

import UIKit


public class WifiReConnectCoordinator: NavigationCoordinator {
    public var parentCoordinator: (any Coordinator)? = nil
    public var childCoordinators: [any Coordinator] = []
    public let navigationController: UINavigationController
    let wifiAutoConnectDIContainer: WifiAutoConnectDIContainer

    let image: UIImage
    let ssid: String
    let password: String

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
        Log.debug("WifiReConnectCoordinator deinit")
    }

    public enum Flow {
        case connecting(image: UIImage, ssid: String, password: String)
        case camera
    }

    public enum FinishFlow {
        case popToRoot
    }

    public func start() {
        let repository = wifiAutoConnectDIContainer.makeWiFiConnectRepository()
        let usecase = wifiAutoConnectDIContainer.makeWiFiConnectUseCase(repository)
        let viewModel = wifiAutoConnectDIContainer.makeWifiReConnectViewModel(wifiConnectUseCase: usecase, coordinatorcontroller: self, imageData: image, ssid: ssid, password: password)
        let viewController = wifiAutoConnectDIContainer.makeWifiReConnectViewController(viewModel)

        if #available(iOS 18.0, *) {
            viewController.preferredTransition = .zoom { context in
                return .none
            }
        } else {
            // Fallback on earlier versions
        }

        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }

    public func finish() {
        self.navigationController.popViewController(animated: true)
    }
}

extension WifiReConnectCoordinator: WifiReConnectCoordinatorController {
    public func performTransition(to flow: Flow) {
        switch flow {
        case .camera:
            let coordinator = CameraCoordinator(navigationController: self.navigationController, wifiAutoConnectDIContainer: wifiAutoConnectDIContainer)
            start(childCoordinator: coordinator)

        case .connecting(image: let image, ssid: let ssid, password: let password):
            let coordinator = ConnectingCoordinator(navigationController: self.navigationController, wifiAutoConnectDIContainer: self.wifiAutoConnectDIContainer, image: image, ssid: ssid, password: password)
            print(parentCoordinator)
            start(childCoordinator: coordinator)
        }
    }

    public func performFinish(to flow: FinishFlow) {
        switch flow {
        case .popToRoot:
            finishUntil(CameraCoordinator.self)
        }
    }
}
