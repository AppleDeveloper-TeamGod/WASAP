//
//  ViewController.swift
//  Wasap
//
//  Created by chongin on 10/3/24.
//
import UIKit
import RxSwift
import SnapKit
import CoreLocation

public class WifiReConnectViewController: RxBaseViewController<WifiConnectViewModel>{
    
    private let wifiReConnectView = WifiReConnectView()
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public override func loadView() {
        super.loadView()
        self.view = wifiReConnectView
    }
    
    override init(viewModel: WifiConnectViewModel) {
        super.init(viewModel: viewModel)
        bind(viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind(_ viewModel: WifiConnectViewModel) {
        
        wifiReConnectView.ssidField.rx.text.orEmpty
            .bind(to: viewModel.ssidText)
            .disposed(by: disposeBag)
        
        wifiReConnectView.pwField.rx.text.orEmpty
            .bind(to: viewModel.pwText)
            .disposed(by: disposeBag)
        
        wifiReConnectView.reConnectButton.rx.tap
            .bind(to: viewModel.reConnectButtonTapped)
            .disposed(by: disposeBag)
        
        
        viewModel.completeText
            .drive {  status in
                print(status)
//                self?.wifiReConnectView.statusLabel.text = status
            }
            .disposed(by: disposeBag)
    }
}


