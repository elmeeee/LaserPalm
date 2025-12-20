//
//  ContentView.swift
//  LaserPalm
//
//  Created by Elmee on 19/12/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            switch viewModel.gameState {
            case .menu:
                MenuView(showMenu: .constant(true)) {
                    // Start game
                    viewModel.startGame()
                } onExit: {
                    // Exit app
                    NSApplication.shared.terminate(nil)
                }
                
            case .loading:
                LoadingView(cameraManager: viewModel.cameraManager)
                
            case .ready, .playing:
                GameView(viewModel: viewModel)
                    .onAppear {
                        NSCursor.hide()
                    }
                    .onDisappear {
                        NSCursor.unhide()
                    }
                
            case .paused:
                GameView(viewModel: viewModel)
                    .overlay(
                        VStack(spacing: 30) {
                            Text("PAUSED")
                                .font(.system(size: 60, weight: .bold))
                                .foregroundColor(.white)
                            
                            Button("Back to Menu") {
                                viewModel.showMenu()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.cyan)
                        }
                    )
            }
        }
    }
}
