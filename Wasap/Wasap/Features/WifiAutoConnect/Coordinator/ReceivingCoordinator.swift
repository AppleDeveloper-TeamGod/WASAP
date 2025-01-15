//
//  ReceivingCoordinator.swift
//  Wasap
//
//  Created by Chang Jonghyeon on 11/10/24.
//

import UIKit


public class ReceivingCoordinator: NSObject, NavigationCoordinator {
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
        print("ReceivingCoordinator deinit")
    }

    public enum FinishFlow {
        case pop
        case popToRoot
    }

    public enum Flow {
        case connecting(ssid : String, password : String)
    }

    public func start() {
        let viewModel = wifiAutoConnectDIContainer.makeReceivingViewModel(coordinatorcontroller: self, ssid: ssid ?? "", password: password ?? "")
        let viewController = wifiAutoConnectDIContainer.makeReceivingViewController(viewModel)

        viewController.modalPresentationStyle = .pageSheet
        if let sheet = viewController.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.preferredCornerRadius = 40.0
        }

        viewController.presentationController?.delegate = self
        self.navigationController.present(viewController, animated: true)
    }

    public func finish() {
        self.navigationController.dismiss(animated: true)
    }
}

extension ReceivingCoordinator: ReceivingCoordinatorController {
    public func performTransition(to flow: Flow) {
        switch flow {
        case .connecting(ssid: let ssid, password: let password):
            finishCurrentCoordinator()
            let coordinator = ConnectingCoordinator(navigationController: self.navigationController, wifiAutoConnectDIContainer: self.wifiAutoConnectDIContainer, image: UIImage(), ssid: ssid, password: password)
            start(childCoordinator: coordinator)
        }
    }

    public func performFinish(to flow: FinishFlow) {
        switch flow {
        case .pop:
            finishCurrentCoordinator()
        case .popToRoot:
            finishUntil(CameraCoordinator.self)
        }
    }
}

extension ReceivingCoordinator: UIAdaptivePresentationControllerDelegate {
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        finishCurrentCoordinator()
    }
}

