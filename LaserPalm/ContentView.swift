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
            case .loading:
                LoadingView(cameraManager: viewModel.cameraManager)
            case .ready, .playing:
                GameView(viewModel: viewModel)
            case .paused:
                GameView(viewModel: viewModel)
                    .overlay(
                        Text("PAUSED")
                            .font(.system(size: 60, weight: .bold))
                            .foregroundColor(.white)
                    )
            }
        }
        .onAppear {
            // Hide cursor for immersive experience
            NSCursor.hide()
            
            // Start game initialization
            viewModel.startGame()
        }
        .onDisappear {
            NSCursor.unhide()
        }
    }
}
