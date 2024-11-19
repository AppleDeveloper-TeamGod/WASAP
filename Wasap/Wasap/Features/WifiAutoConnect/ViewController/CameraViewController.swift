//
//  CameraViewController.swift
//  Wasap
//
//  Created by chongin on 10/7/24.
//

import UIKit
import AVFoundation
import RxSwift
import RxGesture
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

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Log.print("view will appear in camera view controller")
    }

    public override func loadView() {
        self.view = cameraView
    }

    private func bind(_ viewModel: CameraViewModel) {
        Observable.combineLatest(cameraView.zoomSlider.rx.value, viewModel.isPinching.asObservable())
            .filter { !$1 }
            .skip(1) // 첫번째 기본 값 설정 무시
            .map(\.0)
            .map { CGFloat($0) }
            .bind(to: viewModel.zoomSliderValue)
            .disposed(by: disposeBag)

        cameraView.takePhotoButton.rx.tap
            .bind(to: viewModel.shutterButtonDidTap)
            .disposed(by: disposeBag)

        cameraView.previewContainerView.rx.pinchGesture()
            .bind(to: viewModel.zoomPinchGestureDidChange)
            .disposed(by: disposeBag)

        cameraView.tipButtonView.rx.tapGesture()
            .filter { event in event.numberOfTouches > 0 }
            .map { _ in () }
            .bind(to: viewModel.tipButtonDidTap)
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
                    self?.cameraView.qrRectLayer.isHidden = false
                } else {
                    self?.cameraView.qrRectLayer.isHidden = true
                    self?.cameraView.qrRectLayer.frame = .zero
                }
                self?.cameraView.setNeedsLayout()
            }
            .disposed(by: disposeBag)

        viewModel.ssidRect
            .drive { [weak self] rect in
                if let rect, self?.checkRect(rect) == true {
                    self?.cameraView.ssidRectLayer.frame = rect
                    self?.cameraView.ssidRectLayer.isHidden = false
                } else {
                    self?.cameraView.ssidRectLayer.isHidden = true
                    self?.cameraView.ssidRectLayer.frame = .zero
                }
                self?.cameraView.setNeedsLayout()
            }
            .disposed(by: disposeBag)

        viewModel.passwordRect
            .drive { [weak self] rect in
                if let rect, self?.checkRect(rect) == true {
                    self?.cameraView.passwordRectLayer.frame = rect
                    self?.cameraView.passwordRectLayer.isHidden = false
                } else {
                    self?.cameraView.passwordRectLayer.isHidden = true
                    self?.cameraView.passwordRectLayer.frame = .zero
                }
                self?.cameraView.setNeedsLayout()
            }
            .disposed(by: disposeBag)

        viewModel.zoomValue
            .drive { [weak self] value in
                self?.cameraView.zoomSlider.value = Float(value)
            }
            .disposed(by: disposeBag)

        viewModel.minMaxZoomFactor
            .drive { [weak self] value in
                self?.cameraView.zoomSlider.minimumValue = Float(value.min)
                self?.cameraView.zoomSlider.maximumValue = Float(value.max)
            }
            .disposed(by: disposeBag)
    }

    /// 알맞은 프레임 영역 안에 있다면 true, 범위 밖으로 벗어나면 false
    private func checkRect(_ rect: CGRect) -> Bool {
        let cameraFrameRect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.74).insetByPercentage(0.1)

        return rect.intersection(cameraFrameRect) == rect
    }
}
