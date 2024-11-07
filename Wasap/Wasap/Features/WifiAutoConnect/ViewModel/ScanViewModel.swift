//
//  ScanViewModel.swift
//  Wasap
//
//  Created by Chang Jonghyeon on 10/10/24.
//

import RxSwift
import RxCocoa
import UIKit

public class ScanViewModel: BaseViewModel {
    // MARK: - Coordinator
    private weak var coordinatorController: ScanCoordinatorController?

    // MARK: - UseCase
    private let imageAnalysisUseCase: ImageAnalysisUseCase

    // MARK: - Input
    
    // MARK: - Output
    public var updatedImage: Driver<UIImage>

    // MARK: - Properties
    private var ocrResult: Observable<(UIImage, String?, String?)>

    public init(imageAnalysisUseCase: ImageAnalysisUseCase, coordinatorController: ScanCoordinatorController, previewImage: UIImage) {
        self.imageAnalysisUseCase = imageAnalysisUseCase

        let ocrResultRelay = BehaviorRelay<(UIImage, String?, String?)>(value: (previewImage, "", ""))
        self.ocrResult = ocrResultRelay.asObservable().share()

        let updatedImageRelay = BehaviorRelay<UIImage?>(value: nil)
        self.updatedImage = updatedImageRelay.asDriver(onErrorJustReturn: nil).compactMap { $0 }
        
        self.coordinatorController = coordinatorController
        super.init()
        
        viewDidLoad
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .flatMapLatest { owner, _ -> Single<(UIImage, String?, String?)> in
                imageAnalysisUseCase.performOCR(on: previewImage)
            }
            .subscribe {
                Log.debug("OCR 성공")
                ocrResultRelay.accept($0)
            } onError: { error in
                Log.error("OCR 중 에러 발생: \(error.localizedDescription)")
            }
            .disposed(by: disposeBag)

        ocrResult
            .subscribe { imageWithBoxes, _, _ in
                updatedImageRelay.accept(imageWithBoxes)
            }
            .disposed(by: disposeBag)

        ocrResult
            .delay(.milliseconds(1500), scheduler: MainScheduler.asyncInstance)
            .subscribe { _, ssid, password in
                print("OCR 후 SSID: \(ssid), Password: \(password)")
                self.coordinatorController?.performTransition(to: .connecting( imageData: previewImage,ssid: ssid, password: password))
            }
            .disposed(by: disposeBag)
    }
    
    
}
