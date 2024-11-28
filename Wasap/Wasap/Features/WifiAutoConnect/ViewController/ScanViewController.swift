////
////  ScanViewController.swift
////  Wasap
////
////  Created by Chang Jonghyeon on 10/10/24.
////
//
//import RxSwift
//import RxCocoa
//import UIKit
//
//public class ScanViewController: RxBaseViewController<ScanViewModel>, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    private let scanView = ScanView()
//    
//    public override func viewDidLoad() {
//        super.viewDidLoad()
//    }
//    
//    public override func loadView() {
//        super.loadView()
//        self.view = scanView
//    }
//    
//    override init(viewModel: ScanViewModel) {
//        super.init(viewModel: viewModel)
//        bind(viewModel)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    private func bind(_ viewModel: ScanViewModel) {
//        // 뷰 -> 뷰모델
//
//        // 뷰모델 -> 뷰
//        viewModel.updatedImage
//            .drive { [weak self] image in
//                self?.scanView.previewView.image = image
//            }
//            .disposed(by: disposeBag)
//    }
//}
