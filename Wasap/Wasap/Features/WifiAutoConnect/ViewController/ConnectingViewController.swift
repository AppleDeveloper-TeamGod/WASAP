//
//  ConnectingViewController.swift
//  Wasap
//
//  Created by Chang Jonghyeon on 10/14/24.
//

import RxSwift
import RxCocoa
import UIKit
import Lottie

public class ConnectingViewController: RxBaseViewController<ConnectingViewModel> {
    private let connectingView = ConnectingView()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public override func loadView() {
        super.loadView()
        self.view = connectingView
    }
    
    override init(viewModel: ConnectingViewModel) {
        super.init(viewModel: viewModel)
        bind(viewModel)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind(_ viewModel: ConnectingViewModel) {
        // 뷰 -> 뷰모델
        connectingView.quitButton.rx.tap
            .bind(to: viewModel.quitButtonTapped)
            .disposed(by: disposeBag)

        connectingView.shareButton.rx.tap
            .bind(to: viewModel.shareButtonTapped)
            .disposed(by: disposeBag)


        // 뷰모델 -> 뷰
        viewModel.isLoading
            .filter { $0 }
            .drive { [weak self] _ in
                self?.connectingView.mainStatusLabel.isHidden = true
                self?.connectingView.subStatusLabel.isHidden = true
                self?.connectingView.quitButton.isHidden = true
                self?.connectingView.shareButton.isHidden = true
            }
            .disposed(by: disposeBag)
        
        viewModel.isWiFiConnected
            .filter { $0 }
            .drive { [weak self] _ in
                self?.connectingView.loadingAnimation.animation = LottieAnimation.named("DONE")
                self?.connectingView.loadingAnimation.loopMode = .playOnce
                self?.connectingView.loadingAnimation.play()

                self?.connectingView.mainStatusLabel.isHidden = false
                self?.connectingView.subStatusLabel.isHidden = false
                self?.connectingView.quitButton.isHidden = false
                self?.connectingView.shareButton.isHidden = false
            }
            .disposed(by: disposeBag)
    }
}
