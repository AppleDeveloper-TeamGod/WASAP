//
//  WifiConnectUseCase.swift
//  Wasap
//
//  Created by 김상준 on 10/6/24.
//

import RxSwift
import Foundation

public protocol WiFiConnectUseCase {
    func connectToWiFi(ssid: String, password: String) -> Single<Bool>
    func getConnectedSSID() -> String?
}

final class DefaultWiFiConnectUseCase: WiFiConnectUseCase {
    private let repository: WiFiConnectRepository
    
    init(repository: WiFiConnectRepository) {
        self.repository = repository
    }
    
    func connectToWiFi(ssid: String, password: String) -> Single<Bool> {
        return repository.connectToWiFi(ssid: ssid, password: password)
    }

    func getConnectedSSID() -> String? {
        return repository.getConnectedSSID()
    }
}

