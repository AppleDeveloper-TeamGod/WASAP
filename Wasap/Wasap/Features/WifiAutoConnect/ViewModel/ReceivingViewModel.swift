//
//  ReceivingViewModel.swift
//  Wasap
//
//  Created by Chang Jonghyeon on 11/10/24.
//

import RxSwift
import RxCocoa
import UIKit

public class ReceivingViewModel: BaseViewModel {
    // MARK: - Coordinator
    private weak var coordinatorController: ReceivingCoordinatorController?

    // MARK: - Input
    // MARK: - Output

    public init(coordinatorController: ReceivingCoordinatorController, ssid: String, password: String) {

        self.coordinatorController = coordinatorController
        super.init()

    }
}
