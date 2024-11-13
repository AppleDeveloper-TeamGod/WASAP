//
//  WifiShareUseCase.swift
//  Wasap
//
//  Created by Chang Jonghyeon on 11/9/24.
//

import RxSwift
import UIKit
import CoreImage.CIFilterBuiltins

public protocol WiFiShareUseCase {
    func startAdvertising(ssid: String, password: String) -> Observable<Void>
    func startBrowsing() -> Observable<Void>
    func stopAdvertising()
    func stopBrowsing()
    func getConnectedPeerCount() -> Observable<Int>
    func getReceivedWiFiInfo() -> Observable<(ssid: String, password: String)>
    func generateQRCode(ssid: String, password: String) -> Observable<UIImage>
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

    func generateQRCode(ssid: String, password: String) -> Observable<UIImage> {
        return Observable.create { observer in
            let qrString = "WIFI:S:\(ssid);T:WPA;P:\(password);;"

            guard let data = qrString.data(using: .utf8) else {
                observer.onError(WiFiShareErrors.qrCodeError)
                return Disposables.create()
            }

            let qrCodeGenerator = CIFilter.qrCodeGenerator()
            qrCodeGenerator.message = data
            qrCodeGenerator.correctionLevel = "Q"

            guard let ciImage = qrCodeGenerator.outputImage else {
                observer.onError(WiFiShareErrors.qrCodeError)
                return Disposables.create()
            }
            
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledCIImage = ciImage.transformed(by: transform)
            let qrUIImage = UIImage(ciImage: scaledCIImage)

            observer.onNext(qrUIImage)
            observer.onCompleted()

            return Disposables.create()
        }
    }
}
