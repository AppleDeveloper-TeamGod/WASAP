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

    public var maskRect: CGRect {
        CGRect(origin: CGPoint(x: superViewWidth * Dimension.Mask.leftPadding, y: superViewHeight * Dimension.Mask.topPadding), size: CGSize(width: superViewWidth * Dimension.Mask.width, height: superViewHeight * Dimension.Mask.height))
    }

    public lazy var previewContainerView: UIView = {
        UIView()
    }()

    private var wasapLabel: UILabel = {
        let label = UILabel()
        label.text = "WASAP!"
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.textColor = .white
        return label
    }()

    private var wifiIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "wifi"))
        imageView.tintColor = .green200
        return imageView
    }()

    public lazy var takePhotoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "inset.filled.circle"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .clear
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.contentMode = .scaleAspectFit
        return button
    }()

    public lazy var zoomControlButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("1x", for: .normal)
        button.layer.cornerRadius = 23
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 2
        button.tintColor = .white
        button.backgroundColor = .clear
        return button
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

    public lazy var zoomSliderStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            minusImage,
            zoomSlider,
            plusImage,
        ])

        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.alignment = .center
        stackView.backgroundColor = .cameraZoomDisabled
        stackView.layer.cornerRadius = 16

        return stackView
    }()

    public lazy var zoomSlider: CustomSlider = {
        let slider = CustomSlider()
        return slider
    }()

    private lazy var opaqueBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        let maskLayer = CAShapeLayer()
        let path = CGMutablePath()

        path.addRects([
            CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: superViewWidth, height: superViewHeight)),
            maskRect
        ])
        maskLayer.path = path
        maskLayer.fillRule = .evenOdd

        view.layer.mask = maskLayer

        let borderLayer = CAShapeLayer()
        let borderPath = UIBezierPath(rect: maskRect)
        borderLayer.path = borderPath.cgPath
        borderLayer.strokeColor = UIColor.cameraFrameGreen.cgColor
        borderLayer.lineWidth = 6.0
        borderLayer.fillColor = UIColor.clear.cgColor

        view.layer.addSublayer(borderLayer)

        return view
    }()

    override func layoutSubviews() {
        super.layoutSubviews()

        previewLayer?.frame = previewContainerView.bounds
    }

    func setViewHierarchy() {
        self.addSubViews(previewContainerView, opaqueBackgroundView, wasapLabel, wifiIcon, takePhotoButton, zoomControlButton, zoomSliderStack)
    }

    func setConstraints() {
        previewContainerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        opaqueBackgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        wasapLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(safeAreaLayoutGuide).offset(32)
        }

        wifiIcon.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(superViewHeight * 0.3)
        }

        takePhotoButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-16)
            $0.width.height.equalTo(85)
        }

        zoomControlButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(takePhotoButton.snp.top).offset(-52)
            $0.width.height.equalTo(46)
        }

        minusImage.snp.makeConstraints {
            $0.width.equalTo(56)
        }

        plusImage.snp.makeConstraints {
            $0.width.equalTo(56)
        }

        zoomSliderStack.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(takePhotoButton.snp.top).offset(-32)
            $0.width.equalToSuperview().multipliedBy(0.9)
            $0.height.equalTo(84)
        }
    }
}
