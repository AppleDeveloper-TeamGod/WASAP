//
//  EmptyWifiShareRepository.swift
//  Wasap
//
//  Created by chongin on 11/28/24.
//

import Foundation
import RxSwift

final public class EmptyWifiShareRepository: NSObject, WiFiShareRepository {
    public func startAdvertising(ssid: String, password: String) -> RxSwift.Observable<Void> {
        .empty()
    }

    public func startBrowsing() -> RxSwift.Observable<Void> {
        .empty()
    }

    public func stopAdvertising() {

    }

    public func stopBrowsing() {

    }

    public func getConnectedPeerCount() -> RxSwift.Observable<Int> {
        .empty()
    }

    public func getReceivedWiFiInfo() -> RxSwift.Observable<(ssid: String, password: String)> {
        .empty()
    }


}
