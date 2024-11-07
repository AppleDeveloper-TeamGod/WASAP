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

//    public lazy var maskRect: CGRect = {
//        CGRect(origin: CGPoint(x: superViewWidth * Dimension.Mask.leftPadding, y: superViewHeight * Dimension.Mask.topPadding), size: CGSize(width: superViewWidth * Dimension.Mask.width, height: superViewHeight * Dimension.Mask.height))
//    }()

    public lazy var previewContainerView: UIView = {
        UIView()
    }()

    public lazy var bottomBackgroundView: UIView = {
        let view = UIView()
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
        slider.value = 1
        slider.tintColor = .white
        slider.minimumValueImage = UIImage(systemName: "minus")?.withTintColor(.white)
        slider.maximumValueImage = UIImage(systemName: "plus")?.withTintColor(.white)
        return slider
    }()

    public var qrRectLayer: CALayer = {
        let layer = CALayer()
        layer.borderColor = UIColor.green.cgColor
        layer.borderWidth = 2
        return layer
    }()

    public var ssidRectLayer: CALayer = {
        let layer = CALayer()
        layer.borderColor = UIColor.blue.cgColor
        layer.borderWidth = 2
        return layer
    }()

    public var passwordRectLayer: CALayer = {
        let layer = CALayer()
        layer.borderColor = UIColor.yellow.cgColor
        layer.borderWidth = 2
        return layer
    }()

    /// 임시
    public var tempImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    ///

    override func layoutSubviews() {
        super.layoutSubviews()

        previewLayer?.frame = previewContainerView.bounds
    }

    func setViewHierarchy() {
        self.addSubViews(previewContainerView, bottomBackgroundView, zoomSlider, tempImage)

        self.bottomBackgroundView.addSubview(takePhotoButton)

        self.previewContainerView.layer.addSublayer(qrRectLayer)
        self.previewContainerView.layer.addSublayer(ssidRectLayer)
        self.previewContainerView.layer.addSublayer(passwordRectLayer)
    }

    func setConstraints() {
        previewContainerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
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

        minusImage.snp.makeConstraints {
            $0.width.equalTo(56)
        }

        plusImage.snp.makeConstraints {
            $0.width.equalTo(56)
        }

        zoomSlider.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(takePhotoButton.snp.top).offset(-32)
            $0.width.equalToSuperview().multipliedBy(0.7)
            $0.height.equalTo(84)
        }

        tempImage.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.height.equalTo(300)
            $0.width.equalTo(200)
        }
    }
}
