//
//  WifiShareRepository.swift
//  Wasap
//
//  Created by Chang Jonghyeon on 11/9/24.
//

import RxSwift
import MultipeerConnectivity

public protocol WiFiShareRepository {
    func startAdvertising(ssid: String, password: String) -> Single<Void>
    func startBrowsing() -> Single<Void>
    func stopSharing() -> Single<Void>
    func getConnectedPeerCount() -> Observable<Int>
}

final public class DefaultWiFiShareRepository: NSObject, WiFiShareRepository {
    /// multipeer 연결을 구분하기 위해 설정하는 고유 문자열 - 동일 serviceType 기기끼리 연결
    private let serviceType = "wasap-sharing"
    /// 현재 기기 고유 ID
    private let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    /// 연결된 피어들과 데이터를 주고받기 위한 세션
    private var session: MCSession
    /// 이 기기를 다른 피어가 발견할 수 있도록 광고하는 역할
    private var advertiser: MCNearbyServiceAdvertiser?
    /// 탐색을 통해 근처에서 광고 중인 피어를 찾는 역할
    private var browser: MCNearbyServiceBrowser?

    private var isHost: Bool = false
    private var ssidToSend: String = ""
    private var passwordToSend: String = ""

    private let receivedWiFiDetailsSubject = PublishSubject<(String, String)>()
    var receivedWiFiDetails: Observable<(String, String)> {
        return receivedWiFiDetailsSubject.asObservable()
    }
    
    private let connectedPeerCountSubject = BehaviorSubject<Int>(value: 0)

    override init() {
        self.session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        super.init()
        self.session.delegate = self
    }

    /// 송신 기능 - SSID와 Password를 저장하고 광고를 시작
    public func startAdvertising(ssid: String, password: String) -> Single<Void> {
        return Single.create { [weak self] single in
            guard let self = self else {
                single(.failure(WiFiShareErrors.unknownError))
                return Disposables.create()
            }

            self.ssidToSend = ssid
            self.passwordToSend = password
            self.advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
            self.advertiser?.delegate = self

            self.advertiser?.startAdvertisingPeer()
            single(.success(()))

            return Disposables.create {
                self.advertiser?.stopAdvertisingPeer()
            }
        }
    }

    /// 수신 기능 - 탐색을 시작
    public func startBrowsing() -> Single<Void> {
        return Single<Void>.create { [weak self] single in
            guard let self = self else {
                single(.failure(WiFiShareErrors.unknownError))
                return Disposables.create()
            }

            self.browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
            self.browser?.delegate = self

            self.browser?.startBrowsingForPeers()
            single(.success(()))

            return Disposables.create {
                self.browser?.stopBrowsingForPeers()
            }
        }
    }

    /// 송수신 종료
    public func stopSharing() -> Single<Void> {
        return Single<Void>.create { [weak self] single in
            guard let self = self else {
                single(.failure(WiFiShareErrors.unknownError))
                return Disposables.create()
            }
            self.advertiser?.stopAdvertisingPeer()
            self.browser?.stopBrowsingForPeers()
            single(.success(()))

            return Disposables.create()
        }

    }

    public func getConnectedPeerCount() -> Observable<Int> {
        self.connectedPeerCountSubject.asObservable()
    }

    /// ID와 PW를 JSON 형식으로 인코딩하여 연결된 피어에게 전송 (연결된 피어가 없으면 전송하지 않음)
    private func sendWiFiInfo(ssid: String, password: String, peerID: MCPeerID) {
        guard isHost else { return }
        guard !session.connectedPeers.isEmpty else { return }

        let data = ["ssid": ssid, "password": password]
        if let dataToSend = try? JSONSerialization.data(withJSONObject: data, options: []) {
            try? session.send(dataToSend, toPeers: [peerID], with: .reliable)
        }
    }
}

extension DefaultWiFiShareRepository: MCSessionDelegate {
    /// 세션에서 피어의 연결 상태가 변경될 때 호출. 연결된 피어를 관리하고 상태에 따라 peers 배열을 업데이트
    public func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            self.connectedPeerCountSubject.onNext(session.connectedPeers.count)
        }

        /// 새로운 피어가 연결되었을 때
        if state == .connected, isHost {
            sendWiFiInfo(ssid: ssidToSend, password: passwordToSend, peerID: peerID)
        }
    }

    /// 피어로부터 데이터를 수신하면 호출. 수신된 데이터는 JSON 형식으로 디코딩하여 ID와 PW 값을 received에 저장
    public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let dict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String],
           let ssid = dict["ssid"], let password = dict["password"] {
            DispatchQueue.main.async {
                self.receivedWiFiDetailsSubject.onNext((ssid, password))
            }
        }
    }
    
    public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

extension DefaultWiFiShareRepository: MCNearbyServiceAdvertiserDelegate {
    /// 탐색 중인 다른 피어로부터 초대를 수신했을 때 호출. 초대를 수락하면 세션에 연결
    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
}

extension DefaultWiFiShareRepository: MCNearbyServiceBrowserDelegate {
    /// 주변에 광고 중인 피어를 발견하면 호출. 이 피어에 대한 세션 연결 요청을 보냄
    public func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }

    /// 연결이 끊어진 피어를 처리
    public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.connectedPeerCountSubject.onNext(self.session.connectedPeers.count)
        }
    }
}
