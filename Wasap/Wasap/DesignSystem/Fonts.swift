//
//  Fonts.swift
//  Wasap
//
//  Created by Chang Jonghyeon on 10/18/24.
//
import UIKit

// FontProperty 구조체
public struct FontProperty {
    let font: UIFont.FontType
    let size: CGFloat
    let lineHeightMultiple: CGFloat? // 행간(%를 소수로 입력)
    let letterSpacingMultiiple: CGFloat // 자간(%를 소수로 입력)
}

// FontStyle 열거형
public enum FontStyle {
    case title
    case subTitle
    case caption
    case button
    case password_M
    case password_S

    public var fontProperty: FontProperty {
        switch self {
        case .title:
            return FontProperty(font: .gmarketSansBold, size: 26, lineHeightMultiple: 1.0, letterSpacingMultiiple: 0)
        case .subTitle:
            return FontProperty(font: .gmarketSansMedium, size: 16, lineHeightMultiple: 1.0, letterSpacingMultiiple: 0)
        case .caption:
            return FontProperty(font: .gmarketSansMedium, size: 12, lineHeightMultiple: 1.0, letterSpacingMultiiple: 0)
        case .button:
            return FontProperty(font: .gmarketSansMedium, size: 16, lineHeightMultiple: 1.0, letterSpacingMultiiple: 0)
        case .password_M:
            return FontProperty(font: .robotoMonoMedium, size: 20, lineHeightMultiple: 1.0, letterSpacingMultiiple: 0.24)
        case .password_S:
            return FontProperty(font: .robotoMonoRegular, size: 18, lineHeightMultiple: 1.0, letterSpacingMultiiple: 0.24)
        }
    }
}

// FontStyle 확장
public extension FontStyle {
    static let tgTitle = FontStyle.title
    static let tgSubTitle = FontStyle.subTitle
    static let tgCaption = FontStyle.caption
    static let tgButton = FontStyle.button
    static let tgPasswordM = FontStyle.password_M
    static let tgPasswordS = FontStyle.password_S

    var font: UIFont {
        guard let font = UIFont(name: fontProperty.font.name, size: fontProperty.size) else {
            return UIFont()
        }
        return font
    }
}

// UIFont 확장
extension UIFont {
    enum FontType: String {
        case gmarketSansBold = "GmarketSansBold"
        case gmarketSansMedium = "GmarketSansMedium"
        case robotoMonoMedium = "RobotoMono-Medium"
        case robotoMonoRegular = "RobotoMono-Regular"

        var name: String {
            return self.rawValue
        }

        static func font(_ type: FontType, ofsize size: CGFloat) -> UIFont {
            return UIFont(name: type.rawValue, size: size)!
        }
    }
    static var tgTitle: UIFont { FontStyle.title.font }
    static var tgSubTitle: UIFont { FontStyle.subTitle.font }
    static var tgCaption: UIFont { FontStyle.caption.font }
    static var tgButton: UIFont { FontStyle.button.font }
    static var tgPasswordM: UIFont { FontStyle.password_M.font }
    static var tgPasswordS: UIFont { FontStyle.password_S.font }
}

// UILabel 확장
extension UILabel {
    func addLabelSpacing(fontStyle: FontStyle) {
        let lineHeightMultiple = fontStyle.fontProperty.lineHeightMultiple ?? 1.0
        let letterSpacing = fontStyle.fontProperty.letterSpacingMultiiple * font.pointSize

        if let labelText = text, !labelText.isEmpty {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = lineHeightMultiple
            paragraphStyle.alignment = .center

            attributedText = NSAttributedString(
                string: labelText,
                attributes: [
                    .kern: letterSpacing,
                    .paragraphStyle: paragraphStyle
                ]
            )
        }
    }

    // 간단하게 폰트와 스타일 한 번에 설정
    func applyFontSpacing(style: FontStyle) {
        self.font = style.font
        self.addLabelSpacing(fontStyle: style)
    }
}

/*
// 사용 예시
lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.text = "SCAN"
    label.textColor = .textPrimaryHigh
    label.applyFontSpacing(style: .tgTitle) // 폰트와 간격 설정을 간단하게
    return label
}()
*/
