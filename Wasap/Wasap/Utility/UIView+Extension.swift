//
//  UIView+.swift
//  Wasap
//
//  Created by chongin on 10/3/24.
//


import UIKit

extension UIView {
    func addSubViews(_ views: UIView ...) {
        views.forEach { view in
            self.addSubview(view)
        }
    }

    /// Border에 Gradient를 적용합니다.
    func applyGradientBorder(colors: [UIColor], width: CGFloat, cornerRadius: CGFloat = 0) {
        // 기존 Gradient Border Layer 제거
        self.layer.sublayers?.removeAll(where: { $0.name == "GradientBorderLayer" })

        // Gradient Layer 생성
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0) // 위쪽 중앙
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)   // 아래쪽 중앙
        gradientLayer.frame = CGRect(
            x: 0,
            y: 0,
            width: self.bounds.width,
            height: self.bounds.height
        )
        gradientLayer.name = "GradientBorderLayer"

        // 마스크 레이어 생성
        let maskLayer = CAShapeLayer()
        let maskRect = CGRect(
            x: width / 2,
            y: width / 2,
            width: self.bounds.width - width,
            height: self.bounds.height - width
        )
        maskLayer.path = UIBezierPath(
            roundedRect: maskRect,
            cornerRadius: cornerRadius
        ).cgPath
        maskLayer.fillColor = UIColor.clear.cgColor
        maskLayer.strokeColor = UIColor.white.cgColor
        maskLayer.lineWidth = width

        // Gradient Layer에 마스크 설정
        gradientLayer.mask = maskLayer

        // Layer 추가
        self.layer.addSublayer(gradientLayer)
    }

    /// View에 Shadow를 적용합니다.
    func applyShadow(offset: CGSize, radius: CGFloat, color: UIColor, opacity: Float) {
            self.layer.shadowOffset = offset
            self.layer.shadowRadius = radius
            self.layer.shadowColor = color.cgColor
            self.layer.shadowOpacity = opacity
            self.layer.masksToBounds = false
        }
}
