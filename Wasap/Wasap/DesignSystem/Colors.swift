//
//  Colors.swift
//  Wasap
//
//  Created by chongin on 10/9/24.
//

import UIKit

extension UIColor {
    // MARK: - Semantic
    class var primary200: UIColor { UIColor.green200 }
    class var primary500: UIColor { UIColor.green500 }

    class var secondary200: UIColor { UIColor.yellow200 }
    class var secondary500: UIColor { UIColor.yellow500 }

    class var neutralWhite: UIColor { UIColor.white }
    class var neutralBlack: UIColor { UIColor.black }
    class var neutral50: UIColor { UIColor.gray50 }
    class var neutral100: UIColor { UIColor.gray100 }
    class var neutral200: UIColor { UIColor.gray200 }
    class var neutral400: UIColor { UIColor.gray400 }
    class var neutral450: UIColor { UIColor.gray450 }
    class var neutral500: UIColor { UIColor.gray500 }

    // MARK: - Component
    class var textPrimaryLow: UIColor { UIColor.green200.withAlphaComponent(0.7) }
    class var textPrimaryHigh: UIColor { UIColor.green200 }

    class var textSecondaryHigh: UIColor { UIColor.yellow200.withAlphaComponent(0.6) }
    class var textSecondaryLow: UIColor { UIColor.yellow200 }

    class var textNeutralHigh: UIColor { UIColor.gray200 }
    class var textNeutralLow: UIColor { UIColor.gray400 }

    class var buttonDefaultTXT: UIColor { UIColor.gray200 }
    class var buttonDefaultBD: UIColor { UIColor.gray200 }

    class var buttonHoverPrimaryTXT: UIColor { UIColor.green200 }
    class var buttonHoverPrimaryBD: UIColor { UIColor.green200 }
    class var buttonHoverSecondaryTXT: UIColor { UIColor.yellow200 }
    class var buttonHoverSecondaryBD: UIColor { UIColor.yellow200 }

    class var buttonActivePrimaryTXT: UIColor { UIColor.green200 }
    class var buttonActivePrimaryBD: UIColor { UIColor.green200 }
    class var buttonActivePrimaryBG: UIColor { UIColor.green500 }
    class var buttonActiveSecondaryTXT: UIColor { UIColor.yellow200 }
    class var buttonActiveSecondaryBD: UIColor { UIColor.yellow200 }
    class var buttonActiveSecondaryBG: UIColor { UIColor.yellow500 }

    class var buttonPressedPrimaryTXT: UIColor { UIColor.green200 }
    class var buttonPressedPrimaryBD: UIColor { UIColor.green200 }
    class var buttonPressedPrimaryBG: UIColor { UIColor.green500 }

    class var buttonPressedSecondaryTXT: UIColor { UIColor.yellow200 }
    class var buttonPressedSecondaryBD: UIColor { UIColor.yellow200 }
    class var buttonPressedSecondaryBG: UIColor { UIColor.yellow500 }

    class var cameraShutter: UIColor { UIColor.gray50 }

    class var cameraZoomEnabled: UIColor { UIColor.gray50 }
    class var cameraZoomDisabled: UIColor { UIColor.gray500 }

    class var cameraFrame: UIColor { UIColor.gray500.withAlphaComponent(0.8) }
    class var cameraFrameGreen: UIColor { UIColor.green200 }

    class var lightBackground: UIColor { UIColor.gray50 }
    class var darkBackground: UIColor { UIColor.gray500 }

    class var greenGradation: UIColor { UIColor.green200.withAlphaComponent(0.22) }
    class var blueGradation: UIColor { UIColor.blue200.withAlphaComponent(0.5) }
}
