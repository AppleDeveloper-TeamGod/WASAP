//
//  WifiConnectErrors.swift
//  Wasap
//
//  Created by 김상준 on 10/10/24.
//

enum WiFiConnectionErrors: Error {
    case failedToConnect(String)
    case invalidPassword(String)
    case alreadyConnected(String)
    case invalidSSID
    case userDenied
    case notAvailableQRCode

    var localizedDescription: String {
        switch self {
        /// 1) ID&PW 둘 다 틀렸을 때
        /// 2) ID는 틀렸으나 PW 맞을 때
        /// 3)  (다른 와이파이 이미 연결상태) ID는 맞으나 PW가 틀렸을 때
        case .failedToConnect(let ssid):
            return "Failed to connect to \(ssid)"

        /// <Alert없이 바로 retry>
        /// 1) PW가 ""일 때
        /// 2) PW가 8자리 미만
        /// 3) WiFi 라벨과 PW만 있을 때 (로직 상 PW를 ID로 먼저 인식)
        case .invalidPassword(let ssid):
            return "SSID 나 비밀번호가 형식에 맞지 않습니다: \(ssid)"

        /// <Alert없이 바로 retry>
        /// 1) IP&PW 모두 맞으나 해당 WiFi에 이미 접속 상태
        /// 2) ID는 맞으나 PW가 틀렸을 때 (같은 와이파이)
        case .alreadyConnected(let ssid):
            return "이미 \(ssid)에 연결되어 있습니다."

        /// <Alert없이 바로 retry>
        /// 1) ID가 ""일 때
        /// 2) ID&PW가 ""일 때
        case .invalidSSID:
            return "SSID 형식에 맞지 않습니다."

        /// 취소버튼 터치 완료
        case .userDenied:
            return "사용자가 허용하지 않았습니다."

        /// QR코드가 WIFI 형식이 아닐 때
        case .notAvailableQRCode:
            return "QR코드가 WIFI 형식이 아님"

        }
    }
}

