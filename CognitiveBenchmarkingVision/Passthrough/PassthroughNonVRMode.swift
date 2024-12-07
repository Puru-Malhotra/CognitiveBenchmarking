//
//  PassthroughNonVRMode.swift
//  CognitiveBenchmarking
//
//  Created by Rahul on 10/20/24.
//
import SwiftUI

struct PassthroughNonVRMode: View {
    @Environment(PassthroughModuleState.self) private var moduleState
    @State var brightness: CGFloat = 1.0
    @State var saturation: CGFloat = 1.0
    
    var body: some View {
        @Bindable var moduleState = moduleState
        
        VStack {
            HStack {
                RoundedRectangle(cornerRadius: 16.0)
                    .fill(moduleState.currentColor)
                    .frame(width: 300, height: 300)

                Divider()

                RoundedRectangle(cornerRadius: 16.0)
                    .fill(moduleState.currentlySelectedColor)
                    .frame(width: 300, height: 300)

                VStack {
                    CustomColorPickerWheel(
                        bgColor: $moduleState.currentlySelectedColor,
                        brightness: $brightness,
                        saturation: $saturation
                    )
                    .frame(width: 350, height: 325)
                }
            }

            HStack {
                Spacer()
                    .frame(width: 600)

                SaturationSlider(value: $saturation, color: moduleState.currentlySelectedColor)
                    .frame(width: 275, height: 30)
            }

            Button("Next") {
                moduleState.moveToNextColor()
            }
        }
        .padding()
    }
}

#Preview {
    PassthroughNonVRMode()
        .environment(PassthroughModuleState())
}
