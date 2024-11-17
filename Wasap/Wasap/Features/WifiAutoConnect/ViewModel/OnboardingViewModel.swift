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
    public var skipButtonDidTap = PublishRelay<Void>()
    public var nextButtonDidTap = PublishRelay<Void>()
    public var currentPageInput = PublishRelay<Int>()

    // MARK: - Output
    public lazy var currentPageOutput: Driver<Int> = {
        self.currentPageOutputRelay
            .asDriver(onErrorJustReturn: 0)
    }()

    // MARK: - Output Relays
    private var currentPageOutputRelay = BehaviorRelay<Int>(value: 0)

    // MARK: - Properties
    public static var onboardingPages: [UIView.Type] = [OnboardingPage1.self, OnboardingPage2.self]
    private var currentPage = BehaviorSubject<Int>(value: 0)

    // MARK: - Init & Binding
    public init(coordinatorController: OnboardingCoordinatorController) {
        self.coordinatorController = coordinatorController

        super.init()

        skipButtonDidTap
            .subscribe { _ in
                Log.print("Skip!")
            }
            .disposed(by: disposeBag)

        nextButtonDidTap
            .withLatestFrom(self.currentPage)
            .withUnretained(self)
            .subscribe { owner, currentPageNum in
                if currentPageNum == Self.onboardingPages.count - 1 {
                    Log.print("카메라로 이동!")
                } else {
                    owner.currentPage.onNext(currentPageNum + 1)
                }
            }
            .disposed(by: disposeBag)

        currentPageInput
            .bind(to: currentPage)
            .disposed(by: disposeBag)

        currentPage
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: currentPageOutputRelay)
            .disposed(by: disposeBag)
    }
}
