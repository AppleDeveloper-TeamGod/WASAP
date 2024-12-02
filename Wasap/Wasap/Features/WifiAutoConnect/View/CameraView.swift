//
//  CameraView.swift
//  Wasap
//
//  Created by chongin on 10/10/24.
//

import UIKit
import SnapKit
import AVFoundation

enum Dimension {
    enum Mask { // Mask 배율
        static let leftPadding: CGFloat = (1.0 - (331.0 / 393.0)) / 2
        static let topPadding: CGFloat = (1.0 - (216.0 / 852.0)) / 2
        static let width: CGFloat = 331.0 / 393.0
        static let height: CGFloat = 216.0 / 852.0
    }
}

final class CameraView: BaseView {
    var previewLayer: AVCaptureVideoPreviewLayer?
    private var superViewWidth: CGFloat {
        self.frame.size.width
    }

    private var superViewHeight: CGFloat {
        self.frame.size.height
    }

    public lazy var previewContainerView: UIView = {
        UIView()
    }()

    private lazy var photoFrameView: TransparentTouchView = {
        let view = TransparentTouchView()
        return view
    }()

    private lazy var photoFrameBorderLayer: CAShapeLayer = {
        let borderLayer = CAShapeLayer()
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = UIColor.gray400.withAlphaComponent(0.4).cgColor
        borderLayer.lineWidth = 2
        return borderLayer
    }()

    private lazy var photoFrameLayer: CAShapeLayer = {
        let borderLayer = CAShapeLayer()
        borderLayer.strokeColor = UIColor.green200.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.lineWidth = 5
        return borderLayer
    }()

    public lazy var bottomBackgroundView: UIView = {
        let view = UIView()
        let border = UIView()
        border.backgroundColor = .gray450
        border.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        border.frame = CGRect(x: 0, y: 0 , width: view.frame.width, height: 1)
        view.addSubview(border)
        view.backgroundColor = .gray500
        return view
    }()

    public lazy var takePhotoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "Shutter"), for: .normal)
        button.setImage(UIImage(named: "ShutterPressed"), for: .highlighted)
        button.tintColor = .white
        button.backgroundColor = .clear
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.contentMode = .scaleAspectFit
        return button
    }()

    public lazy var tipButtonView: UIImageView = {
        let tipImageView = UIImageView(image: UIImage(named: "HelpCircle"))
        tipImageView.contentMode = .scaleAspectFit
        return tipImageView
    }()

    private lazy var minusImage: UIImageView = {
        let minusImage = UIImageView(image: UIImage(systemName: "minus"))
        minusImage.sizeToFit()
        minusImage.contentMode = .scaleAspectFit
        minusImage.tintColor = .white

        return minusImage
    }()

    private lazy var plusImage: UIImageView = {
        let plusImage = UIImageView(image: UIImage(systemName: "plus"))
        plusImage.sizeToFit()
        plusImage.contentMode = .scaleAspectFit
        plusImage.tintColor = .white

        return plusImage
    }()

    public lazy var zoomSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 1
        slider.maximumValue = 10
        slider.tintColor = .white
        slider.minimumValueImage = UIImage(systemName: "minus")?.withTintColor(.white)
        slider.maximumValueImage = UIImage(systemName: "plus")?.withTintColor(.white)
        return slider
    }()

    private var translucentLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillRule = .evenOdd
        shapeLayer.fillColor = UIColor.black.withAlphaComponent(0.3).cgColor
        return shapeLayer
    }()

    public var qrRectLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.green200.withAlphaComponent(0.3).cgColor
        layer.cornerRadius = 10
        return layer
    }()

    public var ssidRectLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.green200.withAlphaComponent(0.3).cgColor
        layer.cornerRadius = 10
        return layer
    }()

    public var passwordRectLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.green200.withAlphaComponent(0.3).cgColor
        layer.cornerRadius = 10
        return layer
    }()

    public var dimmingLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.black.cgColor
        layer.opacity = 0.0
        return layer
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = previewContainerView.bounds
        dimmingLayer.frame = bounds
        updatePhotoFrameLayerPath()
    }

    func setViewHierarchy() {
        self.addSubViews(previewContainerView, photoFrameView, bottomBackgroundView, zoomSlider)

        self.bottomBackgroundView.addSubViews(takePhotoButton, tipButtonView)

        self.previewContainerView.layer.addSublayer(translucentLayer)
        self.previewContainerView.layer.addSublayer(qrRectLayer)
        self.previewContainerView.layer.addSublayer(ssidRectLayer)
        self.previewContainerView.layer.addSublayer(passwordRectLayer)

        self.photoFrameView.layer.addSublayer(photoFrameBorderLayer)
        self.photoFrameView.layer.addSublayer(photoFrameLayer)

        self.layer.addSublayer(dimmingLayer)
    }

    func setConstraints() {
        previewContainerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        photoFrameView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(32)
            $0.top.equalTo(safeAreaLayoutGuide).inset(92)
            $0.bottom.equalTo(zoomSlider.snp.top).offset(-16)
        }

        bottomBackgroundView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.22)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

        takePhotoButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-16)
            $0.width.height.equalTo(85)
        }

        tipButtonView.snp.makeConstraints {
            $0.centerY.equalTo(self.takePhotoButton)
            $0.width.equalTo(30)
            $0.height.equalTo(30)
            $0.centerX.equalToSuperview().offset(superViewWidth * 0.3)
        }

        minusImage.snp.makeConstraints {
            $0.width.equalTo(56)
        }

        plusImage.snp.makeConstraints {
            $0.width.equalTo(56)
        }

        zoomSlider.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(bottomBackgroundView.snp.top).offset(-16)
            $0.width.equalToSuperview().multipliedBy(0.7)
            $0.height.equalTo(24)
        }
    }

    private func updatePhotoFrameLayerPath() {
        let cornerRadius: CGFloat = 20.0
        let lineLength: CGFloat = 32.0
        let frame = self.photoFrameView.frame


        let fullPath = UIBezierPath(rect: self.bounds)
        let holePath = photoFrameMaskPath(cornerRadius: cornerRadius, frame: frame)

        // 뚫린 부분을 결합
        fullPath.append(holePath)
        fullPath.usesEvenOddFillRule = true

        self.translucentLayer.path = fullPath.cgPath

        let path = UIBezierPath()

        // 왼쪽 상단 모서리
        path.move(to: CGPoint(x: 0, y: cornerRadius + lineLength))
        path.addLine(to: CGPoint(x: 0, y: cornerRadius))
        path.addArc(
            withCenter: CGPoint(x: cornerRadius, y: cornerRadius),
            radius: cornerRadius,
            startAngle: .pi,
            endAngle: .pi * 1.5,
            clockwise: true
        )
        path.addLine(to: CGPoint(x: cornerRadius + lineLength, y: 0))

        // 오른쪽 상단 모서리
        path.move(to: CGPoint(x: frame.width - cornerRadius - lineLength, y: 0))
        path.addLine(to: CGPoint(x: frame.width - cornerRadius, y: 0))
        path.addArc(
            withCenter: CGPoint(x: frame.width - cornerRadius, y: cornerRadius),
            radius: cornerRadius,
            startAngle: .pi * 1.5,
            endAngle: 0,
            clockwise: true
        )
        path.addLine(to: CGPoint(x: frame.width, y: cornerRadius + lineLength))


        // 오른쪽 하단 모서리
        path.move(to: CGPoint(x: frame.width, y: frame.height - cornerRadius - lineLength))
        path.addLine(to: CGPoint(x: frame.width, y: frame.height - cornerRadius))
        path.addArc(
            withCenter: CGPoint(x: frame.width - cornerRadius, y: frame.height - cornerRadius),
            radius: cornerRadius,
            startAngle: 0,
            endAngle: .pi * 0.5,
            clockwise: true
        )
        path.addLine(to: CGPoint(x: frame.width - cornerRadius - lineLength, y: frame.height))

        // 왼쪽 하단 모서리
        path.move(to: CGPoint(x: cornerRadius + lineLength, y: frame.height))
        path.addLine(to: CGPoint(x: cornerRadius, y: frame.height))
        path.addArc(
            withCenter: CGPoint(x: cornerRadius, y: frame.height - cornerRadius),
            radius: cornerRadius,
            startAngle: .pi * 0.5,
            endAngle: .pi,
            clockwise: true
        )
        path.addLine(to: CGPoint(x: 0, y: frame.height - cornerRadius - lineLength))

        photoFrameLayer.path = path.cgPath
        photoFrameBorderLayer.path = UIBezierPath(roundedRect: photoFrameView.bounds.insetBy(dx: -1.0, dy: -1.0), cornerRadius: cornerRadius).cgPath
    }

    private func photoFrameMaskPath(cornerRadius: CGFloat, frame: CGRect) -> UIBezierPath {
        UIBezierPath(roundedRect: frame.insetBy(dx: -1.0, dy: -1.0), cornerRadius: cornerRadius)
    }
}

class TransparentTouchView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return nil
    }
}
