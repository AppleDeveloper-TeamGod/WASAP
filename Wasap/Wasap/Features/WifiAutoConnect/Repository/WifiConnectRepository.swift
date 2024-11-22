//
//  WifiConnectRepository.swift
//  Wasap
//
//  Created by 김상준 on 10/6/24.
//

import RxSwift
import NetworkExtension
import CoreLocation

public protocol WiFiConnectRepository {
    // 와이파이 연결을 시도합니다. 그리고 성공 여부를 반환합니다.
    func connectToWiFi(ssid: String, password: String) -> Single<Bool>
    // 와이파이에 연결된 상태인지 확인합니다.
    func isWiFiConnectedcheck() -> Single<Bool>
    // 연결된 와이파이 SSID 를 반환합니다.
    func getCurrentWiFiSSID() -> Single<String?>
    // 접속을 시도하여 성공한 SSID를 반환합니다.
    func getConnectedSSID() -> String?
}

class DefaultWiFiConnectRepository: WiFiConnectRepository {
    private let disposeBag = DisposeBag()
    private let connectedSSIDSubject = BehaviorSubject<String?>(value: nil)

    // MARK: - Wi-Fi 연결 시도
    public func connectToWiFi(ssid: String, password: String) -> Single<Bool> {
        return Single<Bool>.create { single in
            let config = NEHotspotConfiguration(ssid: ssid,
                                                passphrase: password,
                                                isWEP: false)
            config.joinOnce = false

            /// 접속 여부를 자체적으로 판단 하지 않는다. 따라서 네트워크 연결 상태를 알려주는 함수 필요
            NEHotspotConfigurationManager.shared.apply(config) { error in
                if let err = error as? NSError {
                    switch err.code {
                    case NEHotspotConfigurationError.invalidWPAPassphrase.rawValue:
                        single(.failure(WiFiConnectionErrors.invalidPassword(ssid)))
                    case NEHotspotConfigurationError.alreadyAssociated.rawValue:
                        single(.failure(WiFiConnectionErrors.alreadyConnected(ssid)))
                    case NEHotspotConfigurationError.invalidSSID.rawValue:
                        single(.failure(WiFiConnectionErrors.invalidSSID))
                    case NEHotspotConfigurationError.userDenied.rawValue:
                        Log.print("Alert - 취소버튼 터치 완료")
                        single(.failure(WiFiConnectionErrors.userDenied))
                    default:
                        print("보지 못한 에러입니다.: \(err.localizedDescription)")
                        single(.failure(err))  // 기타 에러 처리
                    }
                }

                // 에러가 없을 경우 와이파이에 접속이 되었는지 판단 하는 과정이 필요
                else {
                    Log.print("Alert - 연결버튼 터치 완료")
                    self.getCurrentWiFiSSID().subscribe(onSuccess: { currentSSID in
                        // 접속하려는 와이파이와 연결된 와이파이가 같음
                        if currentSSID == ssid {
                            self.connectedSSIDSubject.onNext(ssid)
                            single(.success(true))
                        }
                        // 연결된 와이파이가 없거나 접속하려는 와이파이와 다름
                        else {
                            Log.print("'다음 네트워크에 연결할 수 없다' Alert")
                            print("Failed to connect to \(ssid)")
                            single(.failure(WiFiConnectionErrors.failedToConnect(ssid)))
                        }
                    })
                    .disposed(by: self.disposeBag)

                }
            }
            return Disposables.create()
        }
    }

    // MARK: - 비동기 SSID 가져오기
    func getCurrentWiFiSSID() -> Single<String?> {
        return Single<String?>.create { single in
            NEHotspotNetwork.fetchCurrent { network in
                // 연결된 ssid 반환
                if let ssid = network?.ssid {
                    single(.success(ssid))
                }
                // 연결된 ssid가 없음
                else {
                    print("해당 와이파이에 연결되어 있지 않거나 위치 정보가 없습니다.")

                    single(.success(nil))
                }
            }
            return Disposables.create()
        }
    }

    public func getConnectedSSID() -> String? {
        return try? self.connectedSSIDSubject.value()
    }

    // MARK: - Wi-Fi 연결 상태 확인
    func isWiFiConnectedcheck() -> Single<Bool> {
        return getCurrentWiFiSSID().map { ssid in
            return ssid != nil
        }
    }
}
