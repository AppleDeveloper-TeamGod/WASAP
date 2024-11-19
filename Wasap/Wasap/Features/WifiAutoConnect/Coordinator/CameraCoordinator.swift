//
//  CameraCoordinator.swift
//  Wasap
//
//  Created by chongin on 10/10/24.
//

import UIKit

public class CameraCoordinator: NavigationCoordinator {
    public var parentCoordinator: (any Coordinator)? = nil
    public var childCoordinators: [any Coordinator] = []
    public let navigationController: UINavigationController
    let wifiAutoConnectDIContainer: WifiAutoConnectDIContainer

    public init(navigationController: UINavigationController, wifiAutoConnectDIContainer: WifiAutoConnectDIContainer) {
        Log.debug("CameraCoordinator init")
        self.navigationController = navigationController
        self.wifiAutoConnectDIContainer = wifiAutoConnectDIContainer
    }

    public enum Flow {
        case analysis(imageData: UIImage)
        case connectWithQR(ssid: String, password: String)
        case receiving(ssid : String?, password : String?)
        case tip
    }

    public func start() {
        let cameraRepository = wifiAutoConnectDIContainer.makeCameraRepository()
        let cameraUseCase = wifiAutoConnectDIContainer.makeCameraUseCase(cameraRepository)

        let imageAnalysisRepository = wifiAutoConnectDIContainer.makeQuickImageAnalysisRepository()
        let imageAnalysisUseCase = wifiAutoConnectDIContainer.makeImageAnalysisUseCase(imageAnalysisRepository)
        let wifiShareRepository = wifiAutoConnectDIContainer.makeWiFiShareRepository()
        let wifiShareUseCase = wifiAutoConnectDIContainer.makeWiFiShareUseCase(wifiShareRepository)
        let cameraViewModel = wifiAutoConnectDIContainer.makeCameraViewModel(cameraUseCase: cameraUseCase, imageAnalysisUseCase: imageAnalysisUseCase, wifiShareUseCase: wifiShareUseCase, coordinatorcontroller: self)
        let cameraViewController = wifiAutoConnectDIContainer.makeCameraViewController(cameraViewModel)

        self.navigationController.pushViewController(cameraViewController, animated: true)
    }

    public func finish() {
        self.navigationController.popViewController(animated: true)
    }
}

extension CameraCoordinator: CameraCoordinatorController {
    public func performTransition(to flow: Flow) {
        switch flow {
        case .analysis(let imageData):
            let coordinator = ScanCoordinator(navigationController: navigationController, wifiAutoConnectDIContainer: wifiAutoConnectDIContainer, previewImage: imageData)
            start(childCoordinator: coordinator)
        case .connectWithQR(let ssid, let password):
            let coordinator = ConnectingCoordinator(navigationController: navigationController, wifiAutoConnectDIContainer: wifiAutoConnectDIContainer, imageData: nil, ssid: ssid, password: password)
            start(childCoordinator: coordinator)
        case .receiving(ssid: let ssid, password: let password):
            let coordinator = ReceivingCoordinator(navigationController: navigationController, wifiAutoConnectDIContainer: wifiAutoConnectDIContainer, ssid: ssid, password: password)
            start(childCoordinator: coordinator)
        case .tip:
            let coordinator = TipCoordinator(parentViewController: navigationController, wifiAutoConnectDIContainer: wifiAutoConnectDIContainer)
            start(childCoordinator: coordinator)
        }
    }

    public func performFinishSplash() {
        SplashController.shared.finishSplash()
    }
}
