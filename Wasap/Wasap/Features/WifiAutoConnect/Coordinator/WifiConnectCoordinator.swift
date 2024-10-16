//
//  SampleCoordinator.swift
//  Wasap
//
//  Created by 김상준 on 10/7/24.
//

import Foundation
import UIKit

public class WifiConnectCoordinator: NavigationCoordinator {
    public var parentCoordinator: (any Coordinator)? = nil
    public var childCoordinators: [any Coordinator] = []
    public let navigationController: UINavigationController
    let wifiAutoConnectDIContainer: WifiAutoConnectDIContainer

    let image: UIImage
    let ssid : String
    let password: String

    public init(navigationController: UINavigationController, wifiAutoConnectDIContainer: WifiAutoConnectDIContainer, image: UIImage, ssid: String, password: String) {
        self.navigationController = navigationController
        self.wifiAutoConnectDIContainer = wifiAutoConnectDIContainer
        self.image = image
        self.ssid = ssid
        self.password = password
    }
    
    public enum Flow {
        case connecting(imageData: UIImage,ssid : String, password : String)
        case camera
        case gotoSetting(imageData: UIImage,ssid : String, password : String)
    }

    public func start() {
        let repository = wifiAutoConnectDIContainer.makeWiFiConnectRepository()
        let usecase = wifiAutoConnectDIContainer.makeWiFiConnectUseCase(repository)
        let viewModel = wifiAutoConnectDIContainer.makeWifiConnectViewModel(wifiConnectUseCase: usecase, coordinatorcontroller: self, imageData: image, ssid: ssid, password: password)
        let viewController = wifiAutoConnectDIContainer.makeWifiReConnectViewController(viewModel)

        self.navigationController.pushViewController(viewController, animated: true)
    }

    public func finish() {
        self.navigationController.popViewController(animated: true)
    }
}

extension WifiConnectCoordinator: WifiConnectCoordinatorController {
    public func performTransition(to flow: Flow) {
        switch flow {
        case .camera:
            print("Camara View")
            let coordinator = CameraCoordinator(navigationController: self.navigationController, wifiAutoConnectDIContainer: wifiAutoConnectDIContainer)
            start(childCoordinator: coordinator)

        case .connecting(imageData: let imageData,ssid: let ssid, password: let password):
            let coordinator = ConnectingCoordinator(navigationController: self.navigationController, wifiAutoConnectDIContainer: WifiAutoConnectDIContainer(),imageData: imageData, ssid: ssid, password: password)
            start(childCoordinator: coordinator)

        case .gotoSetting(let image, let ssid, let password):
            let coordinator = GoToSettingCoordinator(navigationController: navigationController, wifiAutoConnectDIContainer: wifiAutoConnectDIContainer, imageData: image, ssid: ssid, password: password)
            start(childCoordinator: coordinator)
        }

    }
}

