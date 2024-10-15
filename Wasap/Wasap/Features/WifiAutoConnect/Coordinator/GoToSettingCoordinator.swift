//
//  GotoSettingCoordinator.swift
//  Wasap
//
//  Created by 김상준 on 10/15/24.
//

import Foundation
import UIKit

public class GoToSettingCoordinator: NavigationCoordinator {
    public var childCoordinators: [any Coordinator] = []
    public let navigationController: UINavigationController

    let ssid : String
    let password : String
    let imageData : UIImage

    public init(navigationController: UINavigationController,imageData : UIImage, ssid : String, password : String) {
        self.navigationController = navigationController
        self.ssid = ssid
        self.password = password
        self.imageData = imageData
    }
    
    public enum Flow {
       case camera
    }
    
    public func start() {
        let repository = DefaultGoToSettingRepository()
        
        let usecase = DefaultGoToSettingUseCase(repository: repository)
        
        let viewModel = GoToSettingViewModel(
            gotoSettingUseCase: usecase,
            coordinatorController: self, imageData: imageData,
            ssid: ssid, password: password)

        let viewController = GoToSettingViewController(viewModel: viewModel)


        self.navigationController.pushViewController(viewController, animated: true)
    }
}

extension GoToSettingCoordinator: GoToSettingCoordinatorController {
    public func performTransition(to flow: Flow) {
        switch flow {
        case .camera:
            print("Camara View")
            let coordinator = CameraCoordinator(navigationController: self.navigationController)
            start(childCoordinator: coordinator)
        }

    }
}

