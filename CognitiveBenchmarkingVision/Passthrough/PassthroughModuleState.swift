//
//  PassthroughModuleState.swift
//  CognitiveBenchmarking
//
//  Created by Rahul on 10/20/24.
//

import SwiftUI
import MultipeerConnectivity

@Observable
class PassthroughModuleState {
    struct PassthroughResponse: Codable {
        var date = Date()
        let username: String
        let mode: String
        let targetColor: Color
        let selectedColor: Color

        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(
                keyedBy: PassthroughModuleState.PassthroughResponse.CodingKeys.self
            )
            try container
                .encode(
                    self.date,
                    forKey: PassthroughModuleState.PassthroughResponse.CodingKeys.date
                )
            try container
                .encode(
                    self.username,
                    forKey: PassthroughModuleState.PassthroughResponse.CodingKeys.username
                )
            try container
                .encode(
                    self.mode,
                    forKey: PassthroughModuleState.PassthroughResponse.CodingKeys.mode
                )
            try container
                .encode(
                    self.targetColor.hexString,
                    forKey: PassthroughModuleState.PassthroughResponse.CodingKeys.targetColor
                )
            try container
                .encode(
                    self.selectedColor.hexString,
                    forKey: PassthroughModuleState.PassthroughResponse.CodingKeys.selectedColor
                )
        }

        enum CodingKeys: CodingKey {
            case date
            case username
            case mode
            case targetColor
            case selectedColor
        }

        init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<PassthroughModuleState.PassthroughResponse.CodingKeys> = try decoder.container(
                keyedBy: PassthroughModuleState.PassthroughResponse.CodingKeys.self
            )
            self.date = try container
                .decode(
                    Date.self,
                    forKey: PassthroughModuleState.PassthroughResponse.CodingKeys.date
                )
            self.username = try container
                .decode(
                    String.self,
                    forKey: PassthroughModuleState.PassthroughResponse.CodingKeys.username
                )
            self.mode = try container
                .decode(
                    String.self,
                    forKey: PassthroughModuleState.PassthroughResponse.CodingKeys.mode
                )
            self.targetColor = try Color(hex: container
                .decode(
                    String.self,
                    forKey: PassthroughModuleState.PassthroughResponse.CodingKeys.targetColor
                ))
            self.selectedColor = try Color(hex: container
                .decode(
                    String.self,
                    forKey: PassthroughModuleState.PassthroughResponse.CodingKeys.selectedColor
                ))
        }

        init (
            username: String,
            mode: String,
            targetColor: Color,
            selectedColor: Color
        ) {
            self.username = username
            self.mode = mode
            self.targetColor = targetColor
            self.selectedColor = selectedColor
        }
    }

    struct PassthroughVRModuleData: Codable {
        let selectedColor: Color
    }

    struct PassthroughStateData: Codable {
        let username: String
        let colorIndex: Int
        let screen: Screen?
    }
    
    struct PathData: Codable {
            let location: CGPoint
            let center: CGPoint
            let radius: CGFloat
            let saturation: CGFloat
        }

    enum Screen: String, Codable {
        case login, nonVR, VR, complete
    }

    private var currentUser: String = ""
    

    private var allColors: [Color] {
        [Color.red, Color.blue, Color.green, Color.yellow, Color.purple]
    }

    private(set) var multipeerSession = MultipeerSession()

    var currentScreen: Screen?
    var currentColorIndex = 0
    var currentlySelectedColor: Color = .white
    var currentUserVRResponse: Bool = false
    var currentUserNonVRResponse: Bool = false

    var responses: [PassthroughResponse] = []
    var path: [PathData] = []

    var currentColor: Color {
        allColors[currentColorIndex]
    }

    var isUsernameSet: Bool {
        !currentUser.isEmpty
    }

    init() {
        multipeerSession.receivedDataHandler = self.didReceiveData(_:from:)
        reset()
    }

    func reset() {
        currentUser.removeAll()
        currentScreen = nil
        currentColorIndex = 0
        currentlySelectedColor = .white
        currentUserVRResponse = false
        currentUserNonVRResponse = false
    }

    func beginMultipeerSession() {
        multipeerSession.beginBrowsing()
        multipeerSession.beginAdvertising()
    }

    func endMultipeerSession() {
        multipeerSession.endSession()
    }

    func setCurrentUser(_ user: String) {
        currentUser = user
    }

    func userDidSelectColor() {
        let moduleData = PassthroughVRModuleData(
            selectedColor: self.currentlySelectedColor
        )

        if let data = try? JSONEncoder().encode(moduleData) {
            multipeerSession.sendToAllPeers(data, reliably: true)
        }
    }

    func moveToNextColor() {
        if currentScreen == .nonVR {
            let response = PassthroughResponse(
                username: currentUser,
                mode: currentScreen?.rawValue ?? "nil",
                targetColor: currentColor,
                selectedColor: currentlySelectedColor
            )

            responses.append(response)
            currentlySelectedColor = .white
        }
        
        if currentColorIndex >= allColors.count - 1 {
            currentColorIndex = 0
            Task {
                saveResponses(benchmark: "Passthrough" )
            }
            currentScreen = .complete
        } else {
            currentColorIndex += 1
        }

        let stateData: PassthroughStateData = .init(
            username: currentUser,
            colorIndex: currentColorIndex,
            screen: currentScreen
        )
        
        if let data = try? JSONEncoder().encode(stateData) {
            multipeerSession.sendToAllPeers(data, reliably: true)
        }
        
        savePath()
        path = []
    }
    
    func savePath() {
            #if os(macOS)
            let fileManager = FileManager.default
            let basePath = "\(fileManager.homeDirectoryForCurrentUser.path)/Downloads/CognitiveBenchmarking/Passthrough/Paths/\(currentScreen)/\(currentColorIndex)"

            do {
                try fileManager.createDirectory(atPath: basePath, withIntermediateDirectories: true, attributes: nil)

                let filePath = "\(basePath)/\(currentUser)_path.json"
                var existingData: [PathData] = []

                if fileManager.fileExists(atPath: filePath) {
                    let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
                    existingData = try JSONDecoder().decode([PathData].self, from: data)
                }

                existingData.append(contentsOf: path)

                let jsonData = try JSONEncoder().encode(existingData)
                try jsonData.write(to: URL(fileURLWithPath: filePath))
            } catch {
                print("Error saving data: \(error)")
            }
            #endif
        }

    func saveResponses(benchmark: String) {
        #if os(macOS)
        let fileManager = FileManager.default
        let basePath = "\(fileManager.homeDirectoryForCurrentUser.path)/Downloads/CognitiveBenchmarking/\(benchmark)/\(responses.first?.mode ?? "error")"

        do {
            try fileManager.createDirectory(atPath: basePath, withIntermediateDirectories: true, attributes: nil)

            let filePath = "\(basePath)/\(currentUser)_responses.json"
            var existingData: [PassthroughResponse] = []

            if fileManager.fileExists(atPath: filePath) {
                let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
                existingData = try JSONDecoder()
                    .decode([PassthroughResponse].self, from: data)
            }

            existingData.append(contentsOf: responses)

            let jsonData = try JSONEncoder().encode(
                existingData
            )
            try jsonData.write(to: URL(fileURLWithPath: filePath))
            if let mode = responses.first?.mode {
                if mode == "nonVR" {
                    currentUserNonVRResponse = true
                } else if mode == "VR" {
                    currentUserVRResponse = true
                }
            }
        } catch {
            print("Error saving data: \(error)")
        }
        #endif
    }

    func didReceiveData(_ data: Data, from peer: MCPeerID) {
        print("received data: \(data) from \(peer.displayName)")
        if let data = try? JSONDecoder().decode(
            PassthroughStateData.self,
            from: data
        ) { // this happens on visionOS
            self.currentUser = data.username
            self.currentColorIndex = data.colorIndex
            self.currentScreen = data.screen
            self.currentlySelectedColor = .white
        } else if let data = try? JSONDecoder().decode(
            PassthroughVRModuleData.self,
            from: data
        ) { // this happens on the Mac
            let response = PassthroughResponse(
                username: currentUser,
                mode: currentScreen?.rawValue ?? "nil",
                targetColor: currentColor,
                selectedColor: data.selectedColor
            )

            print("received response: \(response)")

            responses.append(response)
            moveToNextColor()
        }
    }
}
