//
//  OnboardingView.swift
//  Wasap
//
//  Created by chongin on 11/9/24.
//

import UIKit
import SnapKit

final class OnboardingView: BaseView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .black.withAlphaComponent(0.5)
    }
    
    @MainActor required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public var onboardingContentStackView: UIStackView = {
        var onboardingImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.image = UIImage(named: "Onboarding")
            imageView.contentMode = .scaleAspectFit
            return imageView
        }()

        var onboardingLabel: UILabel = {
            let label = UILabel()
            label.text = "와이파이 안내문을 찍으면 네트워크를 연결합니다"
            label.textColor = .white
            label.numberOfLines = 0
            let attrString = NSMutableAttributedString(string: label.text!)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4
            paragraphStyle.alignment = .center
            paragraphStyle.lineBreakMode = .byWordWrapping
            paragraphStyle.lineBreakStrategy = .hangulWordPriority
            attrString.addAttributes([.paragraphStyle: paragraphStyle, .font: FontStyle.title.font], range: NSMakeRange(0, attrString.length))
            label.attributedText = attrString
            return label
        }()

        let stackView = UIStackView(arrangedSubviews: [onboardingImageView, onboardingLabel])
        onboardingImageView.snp.makeConstraints {
            $0.width.height.lessThanOrEqualTo(160).priority(999)
        }
        stackView.spacing = 16
        stackView.axis = .vertical
        return stackView
    }()

}

extension OnboardingView {
    func setViewHierarchy() {
        self.addSubview(onboardingContentStackView)
    }

    func setConstraints() {
        onboardingContentStackView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.75)
        }
    }
}
