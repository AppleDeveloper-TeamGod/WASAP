//
//  OnboardingViewModel.swift
//  Wasap
//
//  Created by chongin on 11/16/24.
//

import UIKit
import RxSwift
import RxCocoa

public class OnboardingViewModel: BaseViewModel {
    // MARK: - Coordinator
    private weak var coordinatorController: OnboardingCoordinatorController?

    // MARK: - Input

    // MARK: - Output

    // MARK: - Init & Binding
    public init(coordinatorController: OnboardingCoordinatorController) {
        self.coordinatorController = coordinatorController
    }
}
