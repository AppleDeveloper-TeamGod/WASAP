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
    case font48
    case font26
    case font24
    case font22
    case font20
    case font18
    case font16
    case font14
    case font12
    case password_M
    case password_S


    public var fontProperty: FontProperty {

        switch self {
        case .font48:
            return FontProperty(font: .gmarketSansBold, size: 48, lineHeightMultiple: 1.0, letterSpacingMultiiple: 0)
        case .font26:
            return FontProperty(font: .gmarketSansBold, size: 26, lineHeightMultiple: 1.0, letterSpacingMultiiple: 0)
        case .font24:
            return FontProperty(font: .gmarketSansMedium, size: 24, lineHeightMultiple: 1.0, letterSpacingMultiiple: 0)
        case .font22:
            return FontProperty(font: .gmarketSansBold, size: 22, lineHeightMultiple: 1.0, letterSpacingMultiiple: 0)
        case .font20:
            return FontProperty(font: .gmarketSansMedium, size: 20, lineHeightMultiple: 1.0, letterSpacingMultiiple: 0)
        case .font18:
            return FontProperty(font: .gmarketSansMedium, size: 18, lineHeightMultiple: 1.0, letterSpacingMultiiple: 0)
        case .font16:
            return FontProperty(font: .gmarketSansMedium, size: 16, lineHeightMultiple: 1.5, letterSpacingMultiiple: 0)
        case .font14:
            return FontProperty(font: .gmarketSansMedium, size: 14, lineHeightMultiple: 1.0, letterSpacingMultiiple: 0)
        case .font12:
            return FontProperty(font: .gmarketSansMedium, size: 12, lineHeightMultiple: 1.0, letterSpacingMultiiple: 0)

        case .password_M:
            return FontProperty(font: .robotoMonoMedium, size: 20, lineHeightMultiple: 1.0, letterSpacingMultiiple: 0.24)
        case .password_S:
            return FontProperty(font: .robotoMonoRegular, size: 18, lineHeightMultiple: 1.0, letterSpacingMultiiple: 0.24)
        }
    }
}

// FontStyle 확장
public extension FontStyle {
    static let tg48 = FontStyle.font48
    static let tg26 = FontStyle.font26
    static let tg24 = FontStyle.font24
    static let tg22 = FontStyle.font22
    static let tg20 = FontStyle.font20
    static let tg18 = FontStyle.font18
    static let tg16 = FontStyle.font16
    static let tg14 = FontStyle.font14
    static let tg12 = FontStyle.font12
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
    static var tg48: UIFont { FontStyle.tg48.font }
    static var tg26: UIFont { FontStyle.tg26.font }
    static var tg24: UIFont { FontStyle.tg24.font }
    static var tg22: UIFont { FontStyle.tg22.font }
    static var tg20: UIFont { FontStyle.tg20.font }
    static var tg18: UIFont { FontStyle.tg18.font }
    static var tg16: UIFont { FontStyle.tg16.font }
    static var tg14: UIFont { FontStyle.tg14.font }
    static var tg12: UIFont { FontStyle.tg12.font }
    static var tgPasswordM: UIFont { FontStyle.password_M.font }
    static var tgPasswordS: UIFont { FontStyle.password_S.font }
}

// UILabel 확장
extension UILabel {
    func addLabelSpacing(fontStyle: FontStyle, lineBreakMode: NSLineBreakMode = .byTruncatingTail) {
        // FontStyle에서 필요한 값 가져오기
        let lineHeightMultiple = fontStyle.fontProperty.lineHeightMultiple ?? 1.0
        let letterSpacing = fontStyle.fontProperty.letterSpacingMultiiple * fontStyle.fontProperty.size

        // NSParagraphStyle 설정
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = lineHeightMultiple
        paragraphStyle.lineBreakMode = lineBreakMode

        // 기존 텍스트 가져오기
        let currentText = text ?? ""
        let currentFont = font ?? fontStyle.font

        // AttributedString 생성
        attributedText = NSAttributedString(
            string: currentText,
            attributes: [
                .font: currentFont,
                .kern: letterSpacing, // 자간 설정
                .paragraphStyle: paragraphStyle
            ]
        )
    }
}


extension UITextField {
    func applyFontSpacing(style: FontStyle) {
        let lineHeightMultiple = style.fontProperty.lineHeightMultiple ?? 1.0
        let letterSpacing = style.fontProperty.letterSpacingMultiiple * style.fontProperty.size

        // NSParagraphStyle 설정
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = lineHeightMultiple
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byTruncatingTail

        // 기본 텍스트 스타일 설정
        self.defaultTextAttributes = [
            .font: style.font,
            .kern: letterSpacing,
            .paragraphStyle: paragraphStyle,
            .foregroundColor: UIColor.neutral200
        ]
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
