//
//  WifiShareErrors.swift
//  Wasap
//
//  Created by Chang Jonghyeon on 11/10/24.
//

enum WiFiShareErrors: Error {
    case wifiShareError
    case qrCodeError

    var localizedDescription: String {
        switch self {
        case .wifiShareError:
            return "error occurred in advertising or browsing"
        case .qrCodeError:
            return "error occurred in generating QR code"
        }
    }
}
