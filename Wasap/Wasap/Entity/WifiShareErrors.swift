//
//  WifiShareErrors.swift
//  Wasap
//
//  Created by Chang Jonghyeon on 11/10/24.
//

enum WiFiShareErrors: Error {
    case advertisingFailed
    case browsingFailed
    case unknownError

    var localizedDescription: String {
        switch self {
        case .advertisingFailed:
            return "Failed to start advertising"
        case .browsingFailed:
            return "Failed to start browsing"
        case .unknownError:
            return "An unknown error occurred."
        }
    }
}
