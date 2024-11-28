//
//  WifiShareRepository.swift
//  Wasap
//
//  Created by Chang Jonghyeon on 11/9/24.
//

import RxSwift

public protocol WiFiShareRepository {
    func startAdvertising(ssid: String, password: String) -> Observable<Void>
    func startBrowsing() -> Observable<Void>
    func stopAdvertising()
    func stopBrowsing()
    func getConnectedPeerCount() -> Observable<Int>
    func getReceivedWiFiInfo() -> Observable<(ssid: String, password: String)>
}
