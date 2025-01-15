//
//  TipCoordinator.swift
//  Wasap
//
//  Created by chongin on 11/19/24.
//

import UIKit

public final class TipCoordinator: NSObject, SheetCoordinator {
    public var parentCoordinator: (any Coordinator)? = nil
    public var childCoordinators: [any Coordinator] = []
    public var parentViewController: UIViewController
    let wifiAutoConnectDIContainer: WifiAutoConnectDIContainer
    private var viewController: UIViewController? = nil

    public init(parentViewController: UIViewController, wifiAutoConnectDIContainer: WifiAutoConnectDIContainer) {
        Log.debug("TipCoordinator init")
        self.parentViewController = parentViewController
        self.wifiAutoConnectDIContainer = wifiAutoConnectDIContainer
    }

    deinit {
        Log.debug("TipCoordinator deinit")
    }

    public enum FinishFlow {
        case close
    }

    public func start() {
        // TODO: DI로 생성하기
        let viewModel = wifiAutoConnectDIContainer.makeTipViewModel(coordinatorController: self)
        self.viewController = wifiAutoConnectDIContainer.makeTipViewController(viewModel)
        viewController?.view.backgroundColor = .gray50
        viewController?.modalPresentationStyle = .pageSheet
        if let sheet = viewController?.sheetPresentationController {
            sheet.detents = [.custom(resolver: { context in
                context.maximumDetentValue * 0.80
            })]
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.preferredCornerRadius = 20.0
        }

        viewController!.presentationController?.delegate = self
        self.parentViewController.present(viewController!, animated: true)
    }

    public func finish() {
        viewController?.dismiss(animated: true)
    }
}

extension TipCoordinator: UIAdaptivePresentationControllerDelegate {
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        finishCurrentCoordinator()
    }
}

extension TipCoordinator: TipCoordinatorController {
    public func performFinish(to finishFlow: FinishFlow) {
        switch finishFlow {
        case .close:
            self.finishCurrentCoordinator()
        }
    }
}
