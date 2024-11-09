//
//  MultipeerSession.swift
//  VisionMultipeerTest
//
//  Created by Rahul on 10/2/24.
//

import SwiftUI
import MultipeerConnectivity

@Observable
class MultipeerSession: NSObject {
    static var deviceName: String {
        #if os(macOS)
        "MY_MAC"
        #else
        "MY_VISION"
        #endif
    }

    private static let serviceType = "vision"

    private(set) var session: MCSession!
    private(set) var serviceAdvertiser: MCNearbyServiceAdvertiser!
    private(set) var serviceBrowser: MCNearbyServiceBrowser!

    var receivedDataHandler: (Data, MCPeerID) -> Void = { _, _ in }
    var connectedPeers: Set<MCPeerID> = []

    var myPeerID: MCPeerID {
        if let data = UserDefaults.standard.data(forKey: "myPeerID") {
            return try! NSKeyedUnarchiver.unarchivedObject(ofClass: MCPeerID.self, from: data)!
        } else {
            let peerID = MCPeerID(displayName: Self.deviceName)
            UserDefaults.standard
                .set(
                    try? NSKeyedArchiver
                        .archivedData(
                            withRootObject: peerID,
                            requiringSecureCoding: false
                        ),
                    forKey: "myPeerID"
                )
            return peerID
        }
    }

    /// - Tag: MultipeerSetup
    override init() {
        super.init()
        
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self

        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: Self.serviceType)
        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: Self.serviceType)

//        beginAdvertising()
//        beginBrowsing()
    }
    
    func endSession() {
        session.disconnect()
        serviceAdvertiser.stopAdvertisingPeer()
        serviceBrowser.stopBrowsingForPeers()
    }
    
    func beginAdvertising() {

        serviceAdvertiser.delegate = self
        serviceAdvertiser.startAdvertisingPeer()
    }
    
    func beginBrowsing() {
        serviceBrowser.delegate = self
        serviceBrowser.startBrowsingForPeers()
    }
    
    func sendToAllPeers(_ data: Data, reliably: Bool) {
        sendToPeers(data, reliably: reliably, peers: session.connectedPeers)
    }
    
    /// - Tag: SendToPeers
    func sendToPeers(_ data: Data, reliably: Bool, peers: [MCPeerID]) {
        guard !peers.isEmpty else { return }
        do {
            try session.send(data, toPeers: peers, with: reliably ? .reliable : .unreliable)
        } catch {
            print("error sending data to peers \(peers): \(error.localizedDescription)")
        }
    }
}

extension MultipeerSession: MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        if state == .connected {
            print("peer \(peerID.displayName) connected")
            connectedPeers.insert(peerID)
        } else if state == .notConnected {
            print("peer \(peerID.displayName) disconnected")
            if connectedPeers.contains(peerID) {
                connectedPeers.remove(peerID)
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            // print("received data")
            self.receivedDataHandler(data, peerID)
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String,
                 fromPeer peerID: MCPeerID) {
        fatalError("This service does not send/receive streams.")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID, with progress: Progress) {
        fatalError("This service does not send/receive resources.")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        fatalError("This service does not send/receive resources.")
    }

}

extension MultipeerSession: MCNearbyServiceBrowserDelegate {
    
    /// - Tag: FoundPeer
    public func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        print("found \(peerID.displayName)")
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 60)
    }

    public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        // DispatchQueue.main.async { self.gameDelegate?.didLosePeer(peerID) }
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 60)
    }
    
}

extension MultipeerSession: MCNearbyServiceAdvertiserDelegate {
    
    /// - Tag: AcceptInvite
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // Call the handler to accept the peer's invitation to join.
        invitationHandler(true, self.session)
        print("received invitation from \(peerID.displayName)")
    }
}

