//
//  TipViewModel.swift
//  Wasap
//
//  Created by chongin on 11/19/24.
//

import UIKit
import RxSwift
import RxCocoa

public class TipViewModel: BaseViewModel {
    // MARK: - Coordinator
    private weak var coordinatorController: TipCoordinatorController?

    // MARK: - Input
    public var closeButtonDidTap = PublishRelay<Void>()
    public var currentPageControlInput = PublishRelay<Int>()
    public var currentScrollViewOffset = PublishRelay<CGPoint>()

    // MARK: - Output
    public lazy var currentPageOutput: Driver<Int> = { [unowned self] in
        self.currentPageOutputRelay
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: 0)
    }()
    public lazy var changeViaPageControl: Driver<Int> = { [unowned self] in
        self.changeViaPageControlRelay
            .asDriver(onErrorDriveWith: .empty())
    }()

    // MARK: - Output Relays
    private var currentPageOutputRelay = BehaviorRelay<Int>(value: 0)
    private var changeViaPageControlRelay = PublishRelay<Int>()


    // MARK: - Properties
    public static var tipPages: [UIView.Type] = [TipPage1.self, TipPage2.self]

    // MARK: - Init & Binding
    public init(coordinatorController: TipCoordinatorController) {
        self.coordinatorController = coordinatorController

        super.init()

        closeButtonDidTap
            .withUnretained(self)
            .subscribe { owner, _ in
                owner.coordinatorController?.performFinish(to: .close)
            }
            .disposed(by: disposeBag)

        currentPageControlInput
            .withUnretained(self)
            .subscribe { owner, page in
                owner.changeViaPageControlRelay.accept(page)
            }
            .disposed(by: disposeBag)
    }
}
