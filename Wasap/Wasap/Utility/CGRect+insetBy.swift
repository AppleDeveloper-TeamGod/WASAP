//
//  CGRect+insetBy.swift
//  Wasap
//
//  Created by chongin on 11/9/24.
//

import CoreGraphics

extension CGRect {
    func insetByPercentage(_ percentage: CGFloat) -> CGRect {
        let widthInset = self.width * percentage
        let heightInset = self.height * percentage
        return self.insetBy(dx: -widthInset, dy: -heightInset)
    }
}
