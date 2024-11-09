//
//  PassthroughLoginView.swift
//  CognitiveBenchmarking
//
//  Created by Rahul on 10/20/24.
//

import SwiftUI

struct PassthroughLoginView: View {
    @Environment(CognitiveBenchmarkingAppState.self) var appState

    @State private var moduleState = PassthroughModuleState()
    @State private var username = ""

    var body: some View {
            VStack {
                #if os(macOS)
                usernameEntryView
                #else
                Button("Begin") { moduleState.currentScreen = .VR }
                #endif
            }
            .navigationDestination(item: $moduleState.currentScreen) { screen in
                switch screen {
                case .login:
                    self
                case .nonVR:
                    PassthroughNonVRMode().environment(moduleState)
                case .VR:
                    PassthroughVRMode().environment(moduleState)
                case .complete:
                    completionView
                }
            }
            .environment(moduleState)
        }

        @ViewBuilder
        private var usernameEntryView: some View {
            VStack(spacing: 20) {
                Text("Welcome to the Passthrough Benchmark")
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 10)

                Text("Please enter your name to continue")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)

                TextField("Username", text: $username)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 5)
                    .padding(.horizontal, 20)
                    .applyTextFieldModifiers()
                    .disabled(moduleState.isUsernameSet)

                if !moduleState.isUsernameSet {
                    Button(action: {
                        moduleState.setCurrentUser(username)
                    }) {
                        Text("Continue")
                            .font(.headline)
                            .bold()
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .disabled(username.isEmpty)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                } else {
                    modeSelectionButtons
                }
            }
            .padding()
        }

        // Buttons for selecting Non-VR and VR modes
        private var modeSelectionButtons: some View {
            HStack(spacing: 20) {
                Button("Non-VR Mode") {
                    moduleState.currentScreen = .nonVR
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.green)
                .cornerRadius(12)
                .disabled(moduleState.currentUserNonVRResponse)

                Button("VR Mode") {
                    moduleState.currentScreen = .VR
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.purple)
                .cornerRadius(12)
                .disabled(moduleState.currentUserVRResponse)
            }
            .padding(.top, 10)
        }

        // View displayed on completion
        private var completionView: some View {
            VStack {
                Text("Completed!")
                    .font(.title)
                    .bold()
                    .padding()

                Button("Reset") {
                    appState.selectedModule = nil
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.red)
                .cornerRadius(12)
            }
            .onDisappear {
                moduleState.endMultipeerSession()
            }
        }
    }


extension View {
    func applyTextFieldModifiers() -> some View {
        #if os(iOS)
        return self
            .textInputAutocapitalization(.words)
            .disableAutocorrection(true)
        #else
        return self
        #endif
    }
}
