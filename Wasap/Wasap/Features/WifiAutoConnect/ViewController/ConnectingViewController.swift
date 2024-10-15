//
//  ConnectingViewController.swift
//  Wasap
//
//  Created by Chang Jonghyeon on 10/14/24.
//

import RxSwift
import RxCocoa
import UIKit

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
        
        // 뷰모델 -> 뷰
        viewModel.isLoading
            .filter { $0 }
            .drive { [weak self] _ in
                self?.connectingView.mainStatusLabel.text = "ASAP!"
                self?.connectingView.subStatusLabel.text = "연결중"
                self?.connectingView.doneSignIcon.isHidden = true
                self?.connectingView.quitButton.isHidden = true
            }
            .disposed(by: disposeBag)
        
        viewModel.isWiFiConnected
            .filter { $0 }
            .drive { [weak self] _ in
                self?.connectingView.mainStatusLabel.text = "Done!"
                self?.connectingView.subStatusLabel.text = "연결 완료!"
                self?.connectingView.doneSignIcon.isHidden = false
                self?.connectingView.quitButton.isHidden = false
            }
            .disposed(by: disposeBag)
    }
}
