//
//  HomeView.swift
//  CognitiveBenchmarking
//
//  Created by Rahul on 10/20/24.
//

import SwiftUI

struct HomeView: View {
    @State var appState = CognitiveBenchmarkingAppState()
    let columns = [GridItem(.adaptive(minimum: 300))]

        private let moduleData: [CognitiveBenchmarkingModule: (title: String, description: String)] = [
            .passthrough: (
                title: "Passthrough Benchmark",
                description: "Evaluates the app's ability to handle passthrough data efficiently and accurately."
            )
        ]

        var body: some View {
            NavigationStack {
                VStack {
                    headerView
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .edgesIgnoringSafeArea(.top)
                        )

                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(CognitiveBenchmarkingModule.allCases) { module in
                                moduleTile(for: module)
                            }
                        }
                        .padding()
                    }
                }
                .background(Color.gray.opacity(0.1))
            }
            .environment(appState)
        }

        private var headerView: some View {
            Text("Cognitive Benchmarking Modules")
                .font(.largeTitle)
                .bold()
                .padding()
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
        }

        private func moduleTile(for module: CognitiveBenchmarkingModule) -> some View {
            let data = moduleData[module] ?? (title: "Unknown Module", description: "No description available.")
            
            return VStack(alignment: .leading, spacing: 8) {
                Text(data.title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(data.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(2)
                
                Spacer()

                NavigationLink(destination: destinationView(for: module)) {
                    Text("Start Benchmark")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.purple)
                        .cornerRadius(8)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 8)
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 200)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
            .padding(.horizontal, 10)
        }

        @ViewBuilder
        private func destinationView(for module: CognitiveBenchmarkingModule) -> some View {
            switch module {
            case .passthrough:
                PassthroughLoginView()
            }
        }
    }

#Preview {
    HomeView()
}
