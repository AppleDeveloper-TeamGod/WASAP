//
//  RxBaseViewController.swift
//  Wasap
//
//  Created by chongin on 10/3/24.
//


import UIKit
import RxSwift

public class RxBaseViewController<VM: BaseViewModelProtocol>: UIViewController {
    let disposeBag = DisposeBag()
    var viewModel: VM

    public init(viewModel: VM) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        _bind(viewModel)

        Log.debug("[VC LifeCycle] \(Self.self) init")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }

    private func _bind(_ viewModel: VM) {
        rx.viewDidLoad
            .bind(to: viewModel.viewDidLoad)
            .disposed(by: disposeBag)

        rx.viewWillAppear
            .bind(to: viewModel.viewWillAppear)
            .disposed(by: disposeBag)

        rx.viewDidAppear
            .bind(to: viewModel.viewDidAppear)
            .disposed(by: disposeBag)

        rx.viewWillDisappear
            .bind(to: viewModel.viewWillDisappear)
            .disposed(by: disposeBag)

        rx.viewDidDisappear
            .bind(to: viewModel.viewDidDisappear)
            .disposed(by: disposeBag)
    }

    deinit {
        Log.debug("[VC LifeCycle] \(Self.self) deinit")
    }
}
