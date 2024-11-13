//
//  SharingCoordinator.swift
//  Wasap
//
//  Created by Chang Jonghyeon on 11/9/24.
//

import UIKit

public protocol SharingCoordinatorController: AnyObject {
    func performFinish(to flow: SharingCoordinator.FinishFlow)
    func performTransition(to flow: SharingCoordinator.Flow)
}

public class SharingCoordinator: NavigationCoordinator {
    public var parentCoordinator: (any Coordinator)? = nil
    public var childCoordinators: [any Coordinator] = []
    public let navigationController: UINavigationController
    let wifiAutoConnectDIContainer: WifiAutoConnectDIContainer

    let ssid: String?
    let password: String?

    public init(navigationController: UINavigationController, wifiAutoConnectDIContainer: WifiAutoConnectDIContainer, ssid: String?, password: String?) {
        self.navigationController = navigationController
        self.wifiAutoConnectDIContainer = wifiAutoConnectDIContainer
        self.ssid = ssid
        self.password = password
    }

    deinit {
        print("SharingCoordinator deinit")
    }

    public enum FinishFlow {
        case pop
    }

    public enum Flow {
        case sharingQR(ssid : String?, password : String?)
    }

    public func start() {
        let wifiShareRepository = wifiAutoConnectDIContainer.makeWiFiShareRepository()
        let wifiShareUseCase = wifiAutoConnectDIContainer.makeWiFiShareUseCase(wifiShareRepository)

        let viewModel = wifiAutoConnectDIContainer.makeSharingViewModel(wifiShareUseCase: wifiShareUseCase, coordinatorcontroller: self, ssid: ssid ?? "", password: password ?? "")
        let viewController = wifiAutoConnectDIContainer.makeSharingViewController(viewModel)

        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }

    public func finish() {
        self.navigationController.popViewController(animated: true)
    }
}

extension SharingCoordinator: SharingCoordinatorController {
    public func performTransition(to flow: Flow) {
        switch flow {
        case .sharingQR(ssid: let ssid, password: let password):
            let coordinator = SharingQRCoordinator(navigationController: self.navigationController, wifiAutoConnectDIContainer: self.wifiAutoConnectDIContainer, ssid: ssid, password: password)
            start(childCoordinator: coordinator)
        }
    }

    public func performFinish(to flow: FinishFlow) {
        switch flow {
        case .pop:
            finishCurrentCoordinator()
        }
    }
}

