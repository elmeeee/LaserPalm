//
//  GameView.swift
//  LaserPalm
//
//  Created by Elmee on 19/12/2025.
//

import SwiftUI

/// Main game view with HUD overlay - Duck Hunt Retro Style
struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var crosshairPosition: CGPoint = .zero
    @State private var screenSize: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Duck Hunt Sky Blue Background
                Color(red: 0.4, green: 0.7, blue: 1.0)
                    .ignoresSafeArea()
                
                // 3D Scene (with transparent background)
                GameSceneView(viewModel: viewModel)
                    .ignoresSafeArea()
                
                // Retro HUD Overlay
                VStack(spacing: 0) {
                    // Top HUD Bar - Retro Style
                    HStack(spacing: 12) {
                        // Score Display
                        VStack(alignment: .leading, spacing: 2) {
                            Text("SCORE")
                                .font(.system(size: 12, weight: .black, design: .monospaced))
                                .foregroundColor(.white)
                                .tracking(1)
                            Text("\(viewModel.stats.score)")
                                .font(.system(size: 36, weight: .black, design: .monospaced))
                                .foregroundColor(.yellow)
                                .shadow(color: .black, radius: 0, x: 2, y: 2)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.black.opacity(0.85))
                        .overlay(
                            Rectangle()
                                .strokeBorder(Color.white, lineWidth: 3)
                        )
                        
                        Spacer()
                        
                        // Pause Button - Retro
                        Button(action: {
                            viewModel.showMenu()
                        }) {
                            Text("PAUSE")
                                .font(.system(size: 14, weight: .black, design: .monospaced))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.black.opacity(0.85))
                                .overlay(
                                    Rectangle()
                                        .strokeBorder(Color.white, lineWidth: 3)
                                )
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                        
                        // Stats Display - Retro
                        VStack(alignment: .trailing, spacing: 4) {
                            HStack(spacing: 6) {
                                Text("HIT:")
                                    .font(.system(size: 11, weight: .black, design: .monospaced))
                                    .foregroundColor(.white)
                                Text("\(viewModel.stats.hits)")
                                    .font(.system(size: 14, weight: .black, design: .monospaced))
                                    .foregroundColor(.green)
                            }
                            HStack(spacing: 6) {
                                Text("MISS:")
                                    .font(.system(size: 11, weight: .black, design: .monospaced))
                                    .foregroundColor(.white)
                                Text("\(viewModel.stats.misses)")
                                    .font(.system(size: 14, weight: .black, design: .monospaced))
                                    .foregroundColor(.red)
                            }
                            HStack(spacing: 6) {
                                Text("ACC:")
                                    .font(.system(size: 11, weight: .black, design: .monospaced))
                                    .foregroundColor(.white)
                                Text("\(String(format: "%.0f", viewModel.stats.accuracy))%")
                                    .font(.system(size: 14, weight: .black, design: .monospaced))
                                    .foregroundColor(.cyan)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.black.opacity(0.85))
                        .overlay(
                            Rectangle()
                                .strokeBorder(Color.white, lineWidth: 3)
                        )
                    }
                    .padding(16)
                    
                    Spacer()
                    
                    // Bottom Status Bar - Retro
                    HStack(spacing: 8) {
                        // Hand Detection Indicator
                        HStack(spacing: 8) {
                            Rectangle()
                                .fill(viewModel.isHandDetected() ? Color.green : Color.red)
                                .frame(width: 16, height: 16)
                                .overlay(
                                    Rectangle()
                                        .strokeBorder(Color.white, lineWidth: 2)
                                )
                            
                            Text(viewModel.isHandDetected() ? "READY" : "NO HAND")
                                .font(.system(size: 13, weight: .black, design: .monospaced))
                                .foregroundColor(.white)
                                .tracking(1)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.85))
                        .overlay(
                            Rectangle()
                                .strokeBorder(Color.white, lineWidth: 3)
                        )
                    }
                    .padding(.bottom, 16)
                }
                
                // Duck Hunt Style Crosshair - Follows hand position
                if viewModel.isHandDetected() {
                    DuckHuntCrosshair()
                        .position(crosshairPosition)
                        .animation(.easeOut(duration: 0.1), value: crosshairPosition)
                }
            }
            .onAppear {
                screenSize = geometry.size
                // Initialize crosshair at center
                crosshairPosition = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
            .onChange(of: viewModel.fingerTipPosition) { newPosition in
                // Update crosshair position based on hand position
                // Vision coordinates are normalized (0-1), need to convert to screen coordinates
                // Mirror X because camera is mirrored (kanan jadi kiri)
                let x = geometry.size.width - (CGFloat(newPosition.x) * geometry.size.width)
                // Flip Y because Vision uses bottom-left origin, SwiftUI uses top-left
                let y = geometry.size.height - (CGFloat(newPosition.y) * geometry.size.height)
                
                crosshairPosition = CGPoint(x: x, y: y)
            }
        }
    }
}

/// Duck Hunt style crosshair
struct DuckHuntCrosshair: View {
    @State private var pulse = false
    
    var body: some View {
        ZStack {
            // Outer circle
            Circle()
                .strokeBorder(Color.red, lineWidth: 4)
                .frame(width: 70, height: 70)
            
            // Inner circle
            Circle()
                .strokeBorder(Color.red, lineWidth: 3)
                .frame(width: 50, height: 50)
            
            // Center dot
            Circle()
                .fill(Color.red)
                .frame(width: 10, height: 10)
                .overlay(
                    Circle()
                        .strokeBorder(Color.white, lineWidth: 2)
                )
            
            // Crosshair lines - Top
            Rectangle()
                .fill(Color.red)
                .frame(width: 3, height: 35)
                .offset(y: -52)
            
            // Bottom
            Rectangle()
                .fill(Color.red)
                .frame(width: 3, height: 35)
                .offset(y: 52)
            
            // Left
            Rectangle()
                .fill(Color.red)
                .frame(width: 35, height: 3)
                .offset(x: -52)
            
            // Right
            Rectangle()
                .fill(Color.red)
                .frame(width: 35, height: 3)
                .offset(x: 52)
        }
        .scaleEffect(pulse ? 1.15 : 1.0)
        .opacity(0.95)
        .shadow(color: .red.opacity(0.6), radius: 15)
        .shadow(color: .black, radius: 2)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}
