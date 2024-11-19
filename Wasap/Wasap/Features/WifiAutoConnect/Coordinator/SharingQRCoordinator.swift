//
//  SharingQRCoordinator.swift
//  Wasap
//
//  Created by Chang Jonghyeon on 11/11/24.
//

import UIKit

public protocol SharingQRCoordinatorController: AnyObject {
    func performFinish(to flow: SharingQRCoordinator.FinishFlow)
}

public class SharingQRCoordinator: NSObject, SheetCoordinator {
    public var parentCoordinator: (any Coordinator)? = nil
    public var childCoordinators: [any Coordinator] = []
    public let parentViewController: UIViewController
    let wifiAutoConnectDIContainer: WifiAutoConnectDIContainer

    let ssid: String?
    let password: String?

    public init(sheetController: UIViewController, wifiAutoConnectDIContainer: WifiAutoConnectDIContainer, ssid: String?, password: String?) {
        self.parentViewController = sheetController
        self.wifiAutoConnectDIContainer = wifiAutoConnectDIContainer
        self.ssid = ssid
        self.password = password
    }

    deinit {
        print("SharingQRCoordinator deinit")
    }

    public enum FinishFlow {
        case pop
    }

    public func start() {
        let wifiShareRepository = wifiAutoConnectDIContainer.makeWiFiShareRepository()
        let wifiShareUseCase = wifiAutoConnectDIContainer.makeWiFiShareUseCase(wifiShareRepository)

        let viewModel = wifiAutoConnectDIContainer.makeSharingQRViewModel(wifiShareUseCase: wifiShareUseCase, coordinatorcontroller: self, ssid: ssid ?? "", password: password ?? "")
        let viewController = wifiAutoConnectDIContainer.makeSharingQRViewController(viewModel)

        viewController.modalPresentationStyle = .pageSheet
        if let sheet = viewController.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.preferredCornerRadius = 20.0
        }

        viewController.presentationController?.delegate = self
        self.parentViewController.present(viewController, animated: true)
    }

    public func finish() {
        self.parentViewController.dismiss(animated: true)
    }
}

extension SharingQRCoordinator: SharingQRCoordinatorController {
    public func performFinish(to flow: FinishFlow) {
        switch flow {
        case .pop:
            finishCurrentCoordinator()
        }
    }
}

extension SharingQRCoordinator: UIAdaptivePresentationControllerDelegate {
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        finishCurrentCoordinator()
    }
}
