//
//  CognitiveBenchmarkingVisionApp.swift
//  CognitiveBenchmarkingVision
//
//  Created by Rahul on 10/20/24.
//

import SwiftUI

@main
struct CognitiveBenchmarkingVisionApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        #if os(macOS)
        .windowIdealSize(.fitToContent)
        #else
        .defaultSize(.init(width: 800, height: 600))
        #endif
    }
}
