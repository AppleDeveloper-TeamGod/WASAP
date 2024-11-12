//
//  WifiConnectUseCaseTests.swift
//  WasapTests
//
//  Created by 김상준 on 10/10/24.
//

import Foundation
import RxSwift
import NetworkExtension
@testable import Wasap
import Testing
import RxSwift
import RxBlocking
import SystemConfiguration.CaptiveNetwork
import UIKit

class MockWifiConnectRepository: WiFiConnectRepository {
    // 현재 Wi-Fi 연결 상태를 확인하는 함수
    func isWiFiConnected() -> Bool {
        return getCurrentWiFiSSID() != nil
    }
    
    // 현재 연결된 Wi-Fi 네트워크의 SSID를 반환하는 함수
    func getCurrentWiFiSSID() -> String? {
        
        let ssid: String = "CorrectSSID"
        
        // 연결된 SSID를 반환하거나, 없으면 nil을 반환
        return ssid
    }
    
    
    // Wi-Fi 연결하는 함수
    func connectToWiFi(ssid: String, password: String) -> Single<Bool> {
        
        let correctSSID: String = "CorrectSSID"
        let correctPW : String = "CorrectPW"
        
        return Single<Bool>.create { single in
            
            if ssid == correctSSID && password == correctPW {
                single(.success(true))
            } else {
                single(.success(false))
            }
            return Disposables.create()
        }
    }

    func isWiFiConnectedcheck() -> RxSwift.Single<Bool> {
        return .just(true)
    }

    func getCurrentWiFiSSID() -> RxSwift.Single<String?> {
        return .just(nil)
    }
}

class MockWiFiConnectUseCase: WiFiConnectUseCase {
    let repository: WiFiConnectRepository
    
    init(repository: WiFiConnectRepository) {
        self.repository = repository
    }
    
    func connectToWiFi(ssid: String, password: String) -> Single<Bool> {
        return repository.connectToWiFi(ssid: ssid, password: password)
    }
}

// MARK: WIFI 연결 USECASE TEST
struct WifiConnectUseCaseTests {
    var mockRepository: MockWifiConnectRepository!
    var useCase: MockWiFiConnectUseCase!
    
    init() async throws {
        mockRepository = MockWifiConnectRepository()
        useCase = MockWiFiConnectUseCase(repository: mockRepository)
    }
    
    // MARK: 와이파이 자동 연결 성공
    @Test
    func testAutoConnectToWiFiSuccess() throws {
        let ssid: String = "CorrectSSID"
        let pw: String = "CorrectPW"
        let result : Bool? = try? useCase.connectToWiFi(ssid: ssid, password: pw).toBlocking().first()
        // 결과 검증
        try #require( result == true)
    }
    
    // MARK: 와이파이 자동 연결 실패
    @Test
    func testAutoConnectToWiFiFailure() throws {
        // 틀린 ssid, pw 일 경우
        let ssid: String = "WrongSSID"
        let pw: String = "WrongPW"
        let result : Bool? = try? useCase.connectToWiFi(ssid: ssid, password: pw).toBlocking().first()
        // 결과 검증
        try #require( result == false)
    }
    
    // MARK: 정보가 달라서 와이파이가 연결이 안됨.
    @Test
    func testDifferentInformation() throws {
        let targetSSID: String = "targetSSID"
        let currentSSID: String? = mockRepository.getCurrentWiFiSSID()
        // 결과 검증
        try #require( targetSSID != currentSSID )
    }
}
