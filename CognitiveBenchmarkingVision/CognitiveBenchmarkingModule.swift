//
//  CognitiveBenchmarkingModule.swift
//  CognitiveBenchmarking
//
//  Created by Rahul on 10/20/24.
//

import SwiftUI

enum CognitiveBenchmarkingModule: String, Hashable, Identifiable, CaseIterable {
    case passthrough = "Passthrough"

    var id: String { rawValue }
}

@Observable
class CognitiveBenchmarkingAppState {
    var selectedModule: CognitiveBenchmarkingModule?
}
