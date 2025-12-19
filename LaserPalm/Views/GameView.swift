//
//  GameView.swift
//  LaserPalm
//
//  Created by Elmee on 19/12/2025.
//

import SwiftUI

/// Main game view with HUD overlay
struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        ZStack {
            // 3D Scene
            GameSceneView(viewModel: viewModel)
                .ignoresSafeArea()
            
            // HUD Overlay
            VStack {
                // Top HUD
                HStack {
                    // Score
                    VStack(alignment: .leading, spacing: 4) {
                        Text("SCORE")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.cyan)
                        Text("\(viewModel.stats.score)")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(12)
                    
                    Spacer()
                    
                    // Stats
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack {
                            Image(systemName: "target")
                                .foregroundColor(.green)
                            Text("Hits: \(viewModel.stats.hits)")
                                .foregroundColor(.white)
                        }
                        HStack {
                            Image(systemName: "xmark.circle")
                                .foregroundColor(.red)
                            Text("Misses: \(viewModel.stats.misses)")
                                .foregroundColor(.white)
                        }
                        HStack {
                            Image(systemName: "percent")
                                .foregroundColor(.cyan)
                            Text("Accuracy: \(String(format: "%.1f", viewModel.stats.accuracy))%")
                                .foregroundColor(.white)
                        }
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(12)
                }
                .padding()
                
                Spacer()
                
                // Bottom HUD - Hand detection indicator
                HStack {
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Circle()
                            .fill(viewModel.isHandDetected() ? Color.green : Color.red)
                            .frame(width: 12, height: 12)
                        
                        Text(viewModel.isHandDetected() ? "Hand Detected" : "No Hand Detected")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                        
                        if viewModel.isHandDetected() {
                            Image(systemName: "hand.point.up.left.fill")
                                .foregroundColor(.cyan)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(20)
                    
                    Spacer()
                }
                .padding(.bottom, 20)
            }
            
            // Crosshair
            if viewModel.isHandDetected() {
                Image(systemName: "scope")
                    .font(.system(size: 40))
                    .foregroundColor(.cyan.opacity(0.8))
            }
        }
        .background(Color.black)
    }
}
