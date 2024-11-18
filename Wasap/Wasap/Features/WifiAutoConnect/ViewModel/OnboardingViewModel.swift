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
    public static var onboardingPages: [UIView.Type] = [OnboardingPage1.self, OnboardingPage2.self]
    private var currentPage = BehaviorSubject<Int>(value: 0)

    // MARK: - Init & Binding
    public init(coordinatorController: OnboardingCoordinatorController) {
        self.coordinatorController = coordinatorController

        super.init()

        skipButtonDidTap
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe { owner, _ in
                Log.print("Skip!")
                owner.coordinatorController?.performStartSplash()
                owner.coordinatorController?.performTransition(to: .camera)
            }
            .disposed(by: disposeBag)

        nextButtonDidTap
            .withLatestFrom(self.currentPage)
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe { owner, currentPageNum in
                if currentPageNum == Self.onboardingPages.count - 1 {
                    Log.print("카메라로 이동!")
                    owner.coordinatorController?.performStartSplash()
                    coordinatorController.performTransition(to: .camera)
                } else {
                    owner.currentPage.onNext(currentPageNum + 1)
                    owner.changeViaPageControlRelay.accept(currentPageNum + 1)
                }
            }
            .disposed(by: disposeBag)

        currentPageControlInput
            .withUnretained(self)
            .subscribe { owner, page in
                owner.currentPage.onNext(page)
                owner.changeViaPageControlRelay.accept(page)
            }
            .disposed(by: disposeBag)

        currentScrollViewOffset
            .map { offset in
                Int(round(offset.x / OnboardingDimensions.contentWidth))
            }
            .bind(to: currentPage)
            .disposed(by: disposeBag)

        currentPage
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: currentPageOutputRelay)
            .disposed(by: disposeBag)
    }
}
