//
//  WifiShareUseCase.swift
//  Wasap
//
//  Created by Chang Jonghyeon on 11/9/24.
//

import RxSwift
import UIKit

public protocol WiFiShareUseCase {
    func startAdvertising(ssid: String, password: String) -> Single<Void>
    func startBrowsing() -> Single<Void>
    func stopSharing() -> Single<Void>
    func getConnectedPeerCount() -> Observable<Int>
}

final class DefaultWiFiShareUseCase: WiFiShareUseCase {
    private let repository: WiFiShareRepository

    init(repository: WiFiShareRepository) {
        self.repository = repository
    }

    func startAdvertising(ssid: String, password: String) -> Single<Void> {
        return repository.startAdvertising(ssid: ssid, password: password)
    }
    
    func startBrowsing() -> Single<Void> {
        return repository.startBrowsing()
    }
    
    func stopSharing() -> Single<Void> {
        return repository.stopSharing()
    }

    func getConnectedPeerCount() -> Observable<Int> {
        return repository.getConnectedPeerCount()
    }
}
