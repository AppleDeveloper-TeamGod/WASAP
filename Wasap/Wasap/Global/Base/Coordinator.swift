//
//  Coordinator.swift
//  Wasap
//
//  Created by chongin on 9/29/24.
//

import UIKit

public protocol Coordinator: AnyObject {
    var parentCoordinator: Coordinator? { get set }
    var childCoordinators: [Coordinator] { get set }

    /// start() : 현재 Coordinator가 시작될 때 할 행동
    /// ** 직접 호출하지 마시오!! **
    /// 보통 DIContainer를 이용해서 뷰모델, 뷰컨 등을 만들고 뷰에 push합니다.
    func start()

    /// finish() : 현재 Coordinator가 종료될 때 할 행동
    /// ** 직접 호출하지 마시오!! **
    /// 보통 어떻게 pop될지 정의합니다. navigation pop 등등.
    func finish()

    func start(childCoordinator: Coordinator)
    func `switch`(childCoordinator: Coordinator)
    func finishChildCoordinator(childCoordinator: Coordinator)
    func removeChildCoordinators()
    func finishCurrentCoordinator()
}

extension Coordinator {
    /// 현재 Coordinator에서 새로운 Coordinator를 시작합니다.
    /// 새로운 Coordinator의 부모는 현재 Coordinator가 됩니다.
    /// 이 함수로 들어온 Coordinator를 바로 start()합니다.
    public func start(childCoordinator: Coordinator) {
        childCoordinator.parentCoordinator = self
        self.childCoordinators.append(childCoordinator)
        childCoordinator.start()
    }

    public func `switch`(childCoordinator: Coordinator) {
        childCoordinator.parentCoordinator = self.parentCoordinator
        finishCurrentCoordinator()
        childCoordinator.parentCoordinator?.start(childCoordinator: childCoordinator)
    }

    /// 현재 Coordinator의 자식 중 인자로 들어온 Coordinator를 종료합니다.
    /// 종료되는 각 Coordinator는 finish() 함수가 추가로 불리게 됩니다.
    /// 종료되는 각 Coordinator들은 parent 정보도 잃게 됩니다.
    /// 재귀적으로 종료합니다.
    public func finishChildCoordinator(childCoordinator: Coordinator) {
        self.childCoordinators.filter { $0 === childCoordinator }
            .forEach {
                $0.parentCoordinator = nil
                $0.removeChildCoordinators()
                $0.finish()
            }
        self.childCoordinators = self.childCoordinators.filter { $0 !== childCoordinator }
    }

    /// 현재 Coordinator가 갖고 있는 모든 자식 Coordinator들을 재귀적으로 종료합니다.
    /// 종료되는 각 Coordinator들은 ``finish()`` 함수가 추가로 불리게 됩니다.
    /// 종료되는 각 Coordinator들을 parent 정보도 잃게 됩니다.
    public func removeChildCoordinators() {
        childCoordinators.forEach {
            $0.parentCoordinator = nil
            $0.removeChildCoordinators()
            $0.finish()
        }
        childCoordinators.removeAll()
    }

    /// 현재 Coordinator를 종료합니다.
    /// finishChildCoordinator를 부르면서 결국 ``finish()`` 함수도 같이 호출합니다.
    /// parentCoordinator 정보가 사라지니 주의하세요.
    public func finishCurrentCoordinator() {
        if let parentCoordinator {
            parentCoordinator.finishChildCoordinator(childCoordinator: self)
        }
    }

    /// 인자로 오는 Coordinator가 현재 Coordinator가 될 때 까지 계속 종료합니다.
    public func finishUntil(_ coordinatorType: Coordinator.Type) {
        Log.debug("now: \(type(of: self)), finish until \(coordinatorType)")
        Log.debug("self != coordinatorType : \("\(type(of: self))" != "\(coordinatorType)")")
        if let parentCoordinator, "\(type(of: self))" != "\(coordinatorType)" {
            Log.debug("parent: \(parentCoordinator)")
            defer { parentCoordinator.finishUntil(coordinatorType) }
            finishCurrentCoordinator()
        }
    }
}

public protocol TabCoordinator: Coordinator {
    var tabBarController: UITabBarController { get }
}

public protocol NavigationCoordinator: Coordinator {
    var navigationController: UINavigationController { get }
}

public protocol SheetCoordinator: Coordinator {
    var parentViewController: UIViewController { get }
}

// MARK: - CoordinatorController ( 추가 )
public protocol WifiReConnectCoordinatorController: AnyObject {
    func performTransition(to flow: WifiReConnectCoordinator.Flow)
    func performFinish(to flow: WifiReConnectCoordinator.FinishFlow)
}

public protocol CameraCoordinatorController: AnyObject {
    func performTransition(to flow: CameraCoordinator.Flow)
    func performFinishSplash()
}

public protocol GoToSettingCoordinatorController: AnyObject {
    func performFinish(to flow: GoToSettingCoordinator.FinishFlow)
    func performPop()
}
