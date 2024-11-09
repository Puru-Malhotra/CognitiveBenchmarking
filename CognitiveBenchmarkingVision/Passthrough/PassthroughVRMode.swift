//
//  PassthroughVRMode.swift
//  CognitiveBenchmarking
//
//  Created by Rahul on 10/20/24.
//

import SwiftUI

struct PassthroughVRMode: View {
    @Environment(PassthroughModuleState.self) private var moduleState

    var body: some View {
        VStack {
            #if os(macOS)
            RoundedRectangle(cornerRadius: 16.0)
                .fill(moduleState.currentColor)
                .frame(width: 200, height: 200)
            #else
            if !moduleState.multipeerSession.connectedPeers.isEmpty {
                PassthroughVRModeVision()
            } else {
                HStack {
                    ProgressView()
                    Text("Connecting...")
                }
            }
            #endif
        }
        .onAppear {
            moduleState.beginMultipeerSession()
        }
    }
}

#if os(visionOS)
struct PassthroughVRModeVision: View {
    @Environment(PassthroughModuleState.self) private var moduleState
    @State var brightness: CGFloat = 1.0
    @State var saturation: CGFloat = 1.0


    var body: some View {
        @Bindable var moduleState = moduleState

        VStack {
//                RoundedRectangle(cornerRadius: 16.0)
//                    .fill(moduleState.currentlySelectedColor)
//                    .frame(width: 200, height: 200)

//                ColorPicker("Color", selection: $moduleState.currentlySelectedColor)
            HStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 8.0)
                    .fill(moduleState.currentlySelectedColor)
                    .frame(width: 300, height: 300)
                
                CustomColorPickerWheel(
                    bgColor: $moduleState.currentlySelectedColor,
                    brightness: $brightness,
                    saturation: $saturation
                )
                .frame(width: 350, height: 350)
            }
            
            HStack {
                Spacer()
                    .frame(width: 300)

                SaturationSlider(value: $saturation, color: moduleState.currentlySelectedColor)
                    .frame(width: 300, height: 40)
            }


            Button("Next") {
                moduleState.userDidSelectColor()
            }
        }
    }
}
#endif
