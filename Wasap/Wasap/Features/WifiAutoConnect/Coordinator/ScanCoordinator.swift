//
//  ScanCoordinator.swift
//  Wasap
//
//  Created by Chang Jonghyeon on 10/10/24.
//

import UIKit

public protocol ScanCoordinatorController: AnyObject {
    func performTransition(to flow: ScanCoordinator.Flow)
}

public class ScanCoordinator: NavigationCoordinator {
    public var parentCoordinator: (any Coordinator)? = nil
    public var childCoordinators: [any Coordinator] = []
    public let navigationController: UINavigationController
    let wifiAutoConnectDIContainer: WifiAutoConnectDIContainer
    let previewImage: UIImage/* = .init(named: "previewTestImage4")!*/

    public init(navigationController: UINavigationController, wifiAutoConnectDIContainer: WifiAutoConnectDIContainer, previewImage: UIImage) {
        self.navigationController = navigationController
        self.wifiAutoConnectDIContainer = wifiAutoConnectDIContainer
        
        self.previewImage = previewImage
    }
    
    public enum Flow {
        case connecting(imageData: UIImage, ssid : String?, password : String?)
        case retry(imageData: UIImage, ssid : String?, password : String?)
    }
    
    public func start() {
        // Repository, UseCase, ViewModel, ViewController 생성
        let imageAnalysisRepository = wifiAutoConnectDIContainer.makeImageAnalysisRepository()
        let imageAnalysisUseCase = wifiAutoConnectDIContainer.makeImageAnalysisUseCase(imageAnalysisRepository)
        
        let viewModel = wifiAutoConnectDIContainer.makeScanViewModel(imageAnalysisUseCase: imageAnalysisUseCase, coordinatorcontroller: self, image: previewImage)
        let viewController = wifiAutoConnectDIContainer.makeScanViewController(viewModel)
        
        // ScanViewController를 navagationController에 push
        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }

    public func finish() {
        self.navigationController.popViewController(animated: true)
    }
}

extension ScanCoordinator: ScanCoordinatorController {
    public func performTransition(to flow: Flow) {
        switch flow {
        case .connecting(imageData: let imageData, ssid: let ssid, password: let password):
            let coordinator = ConnectingCoordinator(navigationController: self.navigationController, wifiAutoConnectDIContainer: self.wifiAutoConnectDIContainer, image: imageData, ssid: ssid, password: password)
            start(childCoordinator: coordinator)
        case .retry(imageData: let image, ssid: let ssid, password: let password):
            let coordinator = WifiReConnectCoordinator(navigationController: navigationController, wifiAutoConnectDIContainer: wifiAutoConnectDIContainer, image: image, ssid: ssid ?? "", password: password ?? "")
            start(childCoordinator: coordinator)
        }
    }
}
