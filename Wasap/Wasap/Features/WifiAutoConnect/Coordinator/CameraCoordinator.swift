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
        self.navigationController = navigationController
        self.wifiAutoConnectDIContainer = wifiAutoConnectDIContainer
    }

    public enum Flow {
        case analysis(imageData: UIImage)
    }

    public func start() {
        let cameraRepository = wifiAutoConnectDIContainer.makeCameraRepository()
        let cameraUseCase = wifiAutoConnectDIContainer.makeCameraUseCase(cameraRepository)
        let imageAnalysisRepository = wifiAutoConnectDIContainer.makeImageAnalysisRepository()
        let imageAnalysisUseCase = wifiAutoConnectDIContainer.makeImageAnalysisUseCase(imageAnalysisRepository)
        let cameraViewModel = wifiAutoConnectDIContainer.makeCameraViewModel(cameraUseCase: cameraUseCase, imageAnalysisUseCase: imageAnalysisUseCase, coordinatorcontroller: self)
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
            print("analysis view! : \(imageData)")
            let coordinator = ScanCoordinator(navigationController: navigationController, wifiAutoConnectDIContainer: wifiAutoConnectDIContainer, previewImage: imageData)
            start(childCoordinator: coordinator)
        }
    }
}
