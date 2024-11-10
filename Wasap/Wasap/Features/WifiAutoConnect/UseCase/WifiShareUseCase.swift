//
//  WifiShareUseCase.swift
//  Wasap
//
//  Created by Chang Jonghyeon on 11/9/24.
//

import RxSwift
import UIKit

public protocol WiFiShareUseCase {
    func startAdvertising(ssid: String, password: String) -> Observable<Void>
    func startBrowsing() -> Observable<Void>
    func stopAdvertising()
    func stopBrowsing()
    func getConnectedPeerCount() -> Observable<Int>
    func getReceivedWiFiInfo() -> Observable<(ssid: String, password: String)>
}

final class DefaultWiFiShareUseCase: WiFiShareUseCase {
    private let repository: WiFiShareRepository

    init(repository: WiFiShareRepository) {
        self.repository = repository
    }

    func startAdvertising(ssid: String, password: String) -> Observable<Void> {
        return repository.startAdvertising(ssid: ssid, password: password)
    }

    func startBrowsing() -> Observable<Void> {
        return repository.startBrowsing()
    }

    func stopAdvertising() {
        return repository.stopAdvertising()
    }

    func stopBrowsing() {
        return repository.stopBrowsing()
    }

    func getConnectedPeerCount() -> Observable<Int> {
        return repository.getConnectedPeerCount()
    }

    func getReceivedWiFiInfo() -> Observable<(ssid: String, password: String)> {
        return repository.getReceivedWiFiInfo()
    }
}
