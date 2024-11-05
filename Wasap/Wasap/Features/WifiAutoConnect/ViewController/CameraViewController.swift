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
        viewModel.previewLayer
            .drive { [weak self] previewLayer in
                Log.debug("preview layer on VC : \(previewLayer)")
                self?.cameraView.previewLayer = previewLayer
                self?.cameraView.previewContainerView.layer.addSublayer(previewLayer)
                self?.cameraView.previewLayer?.frame = (self?.cameraView.previewContainerView.bounds)!
            }
            .disposed(by: disposeBag)

        viewModel.isZoomControlButtonHidden
            .drive { [weak self] isHidden in
                self?.cameraView.zoomControlButton.isHidden = isHidden
                self?.cameraView.zoomSliderStack.isHidden = !isHidden
            }
            .disposed(by: disposeBag)

        cameraView.zoomControlButton.rx.tap
            .bind(to: viewModel.zoomControlButtonDidTap)
            .disposed(by: disposeBag)

        cameraView.zoomSlider.rx.currentSteppedValue
            .map { CGFloat($0) }
            .bind(to: viewModel.zoomValue)
            .disposed(by: disposeBag)

        cameraView.zoomSlider.rx.currentSteppedValue
            .map { String(Int($0)) + "x" }
            .subscribe { [weak self] in
                self?.cameraView.zoomControlButton.setTitle($0, for: .normal)
            }
            .disposed(by: disposeBag)

//        cameraView.takePhotoButton.rx.tap
//            .compactMap { [weak self] _ in self?.cameraView.maskRect }
//            .bind(to: viewModel.shutterButtonDidTapWithMask)
//            .disposed(by: disposeBag)

        viewModel.qrCodeCorners
            .drive { [weak self] corners in
                print("corners : \(corners)")
                if let corners, !corners.isEmpty {
                    guard !corners.isEmpty else { return }

                    let minX = corners.map { $0.x }.min() ?? 0
                    let minY = corners.map { $0.y }.min() ?? 0
                    let maxX = corners.map { $0.x }.max() ?? 0
                    let maxY = corners.map { $0.y }.max() ?? 0

                    let width = maxX - minX
                    let height = maxY - minY

                    let rect = CGRect(x: minX, y: minY, width: width, height: height)
                    self?.cameraView.frameRectLayer.frame = rect
                } else {
                    self?.cameraView.frameRectLayer.frame = CGRect(x: 50, y: 100, width: 300, height: 200)
                }
            }
            .disposed(by: disposeBag)
    }

}
