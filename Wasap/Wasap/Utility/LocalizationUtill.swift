//
//  LocalizationUtill.swift
//  Wasap
//
//  Created by 김상준 on 10/28/24.
//

import Foundation

extension String {
    func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
        return NSLocalizedString(self, tableName: tableName, value: self, comment: "")
    }
}
