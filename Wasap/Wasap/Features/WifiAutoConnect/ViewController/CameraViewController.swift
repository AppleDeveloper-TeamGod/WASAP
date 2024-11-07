//
//  CameraViewController.swift
//  Wasap
//
//  Created by chongin on 10/7/24.
//

import UIKit
import AVFoundation
import RxSwift
import CoreLocation

public class CameraViewController: RxBaseViewController<CameraViewModel> {
    private let cameraView = CameraView()

    override init(viewModel: CameraViewModel) {
        super.init(viewModel: viewModel)
        bind(viewModel)
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func loadView() {
        self.view = cameraView

    }

    private func bind(_ viewModel: CameraViewModel) {
        cameraView.zoomSlider.rx.value
            .map { CGFloat($0) }
            .bind(to: viewModel.zoomValue)
            .disposed(by: disposeBag)

        cameraView.takePhotoButton.rx.tap
            .bind(to: viewModel.shutterButtonDidTap)
            .disposed(by: disposeBag)

        cameraView.previewContainerView.rx.pinchGesture()
            .subscribe { [weak self] pinch in
                print("pinch : \(pinch)")
            }
            .disposed(by: disposeBag)

        viewModel.previewLayer
            .drive { [weak self] previewLayer in
                Log.debug("preview layer on VC : \(previewLayer)")
                self?.cameraView.previewLayer = previewLayer
                self?.cameraView.previewContainerView.layer.addSublayer(previewLayer)
                self?.cameraView.previewLayer?.frame = (self?.cameraView.previewContainerView.bounds)!
            }
            .disposed(by: disposeBag)

        viewModel.qrCodePoints
            .drive { [weak self] points in
                if let points, points.count == 4 {

                    let minX = points.map { $0.x }.min() ?? 0
                    let minY = points.map { $0.y }.min() ?? 0
                    let maxX = points.map { $0.x }.max() ?? 0
                    let maxY = points.map { $0.y }.max() ?? 0

                    let width = maxX - minX
                    let height = maxY - minY

                    let rect = CGRect(x: minX, y: minY, width: width, height: height)
                    self?.cameraView.qrRectLayer.frame = rect
                } else {
                    self?.cameraView.qrRectLayer.frame = .zero
                }
            }
            .disposed(by: disposeBag)

        viewModel.ssidRect
            .drive { [weak self] rect in
                if let rect {
                    self?.cameraView.ssidRectLayer.frame = rect
                } else {
                    self?.cameraView.ssidRectLayer.frame = .zero
                }
            }
            .disposed(by: disposeBag)

        viewModel.passwordRect
            .drive { [weak self] rect in
                if let rect {
                    self?.cameraView.passwordRectLayer.frame = rect
                } else {
                    self?.cameraView.passwordRectLayer.frame = .zero
                }
            }
            .disposed(by: disposeBag)

        viewModel.tempImage
            .drive { [weak self] image in
                self?.cameraView.tempImage.image = image
            }
            .disposed(by: disposeBag)
    }

}
