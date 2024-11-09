//
//  WifiShareUseCase.swift
//  Wasap
//
//  Created by Chang Jonghyeon on 11/9/24.
//

import RxSwift
import UIKit

public protocol WiFiShareUseCase {
    func startSending(ssid: String, password: String)
    func startReceiving()
    func stopSharing()
}

final class DefaultWiFiShareUseCase: WiFiShareUseCase {
    private let repository: WiFiShareRepository

    init(repository: WiFiShareRepository) {
        self.repository = repository
    }

    func startSending(ssid: String, password: String) {
        repository.startAdvertising(ssid: ssid, password: password)
    }
    
    func startReceiving() {
        repository.startBrowsing()
    }
    
    func stopSharing() {
        repository.stopSharing()
    }
}
