//
//  ConnectingCoordinator.swift
//  Wasap
//
//  Created by Chang Jonghyeon on 10/14/24.
//

import UIKit

public protocol ConnectingCoordinatorController: AnyObject {
    func performFinish(to flow: ConnectingCoordinator.FinishFlow)
    func performTransition(to flow: ConnectingCoordinator.Flow)
}

public class ConnectingCoordinator: NavigationCoordinator {
    public var parentCoordinator: (any Coordinator)? = nil
    public var childCoordinators: [any Coordinator] = []
    public let navigationController: UINavigationController
    let wifiAutoConnectDIContainer: WifiAutoConnectDIContainer
    
    let image: UIImage?
    let ssid: String?
    let password: String?
    
    private weak var connectingViewController: ConnectingViewController?
    
    public init(navigationController: UINavigationController, wifiAutoConnectDIContainer: WifiAutoConnectDIContainer, image: UIImage?, ssid: String?, password: String?) {
        self.navigationController = navigationController
        self.wifiAutoConnectDIContainer = wifiAutoConnectDIContainer
        self.ssid = ssid
        self.password = password
        self.image = image
    }

    deinit {
        Log.debug("ConnectingCoordinator deinit")
    }

    public enum FinishFlow {
        case popToRoot
        case finishWithError
    }
    
    public enum Flow {
        case sharing(ssid : String?, password : String?)
    }
    
    public func start() {
        let wifiConnectRepository = wifiAutoConnectDIContainer.makeWiFiConnectRepository()
        let wifiConnectUseCase = wifiAutoConnectDIContainer.makeWiFiConnectUseCase(wifiConnectRepository)

        let viewModel = wifiAutoConnectDIContainer.makeConnectingViewModel(wifiConnectUseCase: wifiConnectUseCase, coordinatorcontroller: self, ssid: ssid ?? "", password: password ?? "")
        let viewController = wifiAutoConnectDIContainer.makeConnectingViewController(viewModel)

        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    public func finish() {
        self.navigationController.popViewController(animated: true)
    }
}

extension ConnectingCoordinator: ConnectingCoordinatorController {
    public func performTransition(to flow: Flow) {
        switch flow {
        case .sharing(ssid: let ssid, password: let password):
            let coordinator = SharingCoordinator(navigationController: self.navigationController, wifiAutoConnectDIContainer: self.wifiAutoConnectDIContainer, ssid: ssid, password: password)
            start(childCoordinator: coordinator)
        }
    }
    
    public func performFinish(to flow: FinishFlow) {
        switch flow {
        case .popToRoot:
            finishUntil(CameraCoordinator.self)
        case .finishWithError:
            if parentCoordinator is CameraCoordinator, image != nil {
                let coordinator = WifiReConnectCoordinator(navigationController: navigationController, wifiAutoConnectDIContainer: wifiAutoConnectDIContainer, image: image!, ssid: ssid ?? "", password: password ?? "")
                self.switch(childCoordinator: coordinator)
            } else if parentCoordinator is WifiReConnectCoordinator, image != nil {
                let coordinator = GoToSettingCoordinator(navigationController: navigationController, wifiAutoConnectDIContainer: wifiAutoConnectDIContainer, image: image!, ssid: ssid ?? "", password: password ?? "")
                self.switch(childCoordinator: coordinator)
            } else if let parentCoordinator = parentCoordinator as? ReceivingCoordinator {
                finishCurrentCoordinator()
                parentCoordinator.performFinish(to: .popToRoot)
            } else {
                finishCurrentCoordinator()
                Toaster.shared.importantToast("연결에 실패했어요")
            }
        }
    }
}
