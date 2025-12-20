//
//  GameView.swift
//  LaserPalm
//
//  Created by Elmee on 19/12/2025.
//

import SwiftUI

/// Main game view - Modern Clean Design with Environment Backgrounds
struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var crosshairPosition: CGPoint = .zero
    @State private var screenSize: CGSize = .zero
    
    // Environment (will be dynamic based on level)
    @State private var currentEnvironment: GameEnvironment = .forest
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Environment Background
                currentEnvironment.background
                    .ignoresSafeArea()
                
                // 3D Scene (with transparent background)
                GameSceneView(viewModel: viewModel)
                    .ignoresSafeArea()
                
                // Modern Clean HUD
                VStack(spacing: 0) {
                    // Top HUD Bar
                    HStack(spacing: 12) {
                        // Score Display
                        VStack(alignment: .leading, spacing: 4) {
                            Text("SCORE")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(Color(nsColor: .secondaryLabelColor))
                            Text("\(viewModel.stats.score)")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(Color(nsColor: .labelColor))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        
                        Spacer()
                        
                        // Level Info
                        HStack(spacing: 8) {
                            Image(systemName: currentEnvironment.icon)
                                .font(.system(size: 16, weight: .medium))
                            Text(currentEnvironment.name)
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundStyle(Color(nsColor: .labelColor))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        
                        Spacer()
                        
                        // Pause Button
                        Button(action: {
                            viewModel.showMenu()
                        }) {
                            Image(systemName: "pause.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(Color(nsColor: .labelColor))
                                .frame(width: 44, height: 44)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(16)
                    
                    Spacer()
                    
                    // Bottom Stats Bar
                    HStack(spacing: 16) {
                        // Hits
                        StatCard(
                            icon: "checkmark.circle.fill",
                            label: "Hits",
                            value: "\(viewModel.stats.hits)",
                            color: .green
                        )
                        
                        // Misses
                        StatCard(
                            icon: "xmark.circle.fill",
                            label: "Misses",
                            value: "\(viewModel.stats.misses)",
                            color: .red
                        )
                        
                        // Accuracy
                        StatCard(
                            icon: "percent",
                            label: "Accuracy",
                            value: "\(String(format: "%.0f", viewModel.stats.accuracy))%",
                            color: .blue
                        )
                        
                        // Hand Status
                        HStack(spacing: 8) {
                            Circle()
                                .fill(viewModel.isHandDetected() ? Color.green : Color.red)
                                .frame(width: 8, height: 8)
                            
                            Text(viewModel.isHandDetected() ? "Ready" : "No Hand")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color(nsColor: .secondaryLabelColor))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
                
                // Modern Crosshair - Follows hand position
                if viewModel.isHandDetected() {
                    ModernCrosshair()
                        .position(crosshairPosition)
                        .animation(.easeOut(duration: 0.1), value: crosshairPosition)
                }
            }
            .onAppear {
                screenSize = geometry.size
                crosshairPosition = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
            .onChange(of: viewModel.fingerTipPosition) { oldValue, newPosition in
                // Mirror X because camera is mirrored
                let x = geometry.size.width - (CGFloat(newPosition.x) * geometry.size.width)
                // Flip Y because Vision uses bottom-left origin
                let y = geometry.size.height - (CGFloat(newPosition.y) * geometry.size.height)
                
                crosshairPosition = CGPoint(x: x, y: y)
            }
        }
    }
}

/// Stat Card Component
struct StatCard: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color(nsColor: .secondaryLabelColor))
                Text(value)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(nsColor: .labelColor))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

/// Modern Crosshair - Clean and minimal
struct ModernCrosshair: View {
    @State private var pulse = false
    
    var body: some View {
        ZStack {
            // Outer ring
            Circle()
                .strokeBorder(Color.white, lineWidth: 2)
                .frame(width: 50, height: 50)
            
            // Inner ring
            Circle()
                .strokeBorder(Color.white.opacity(0.6), lineWidth: 1.5)
                .frame(width: 30, height: 30)
            
            // Center dot
            Circle()
                .fill(Color.red)
                .frame(width: 6, height: 6)
            
            // Crosshair lines
            Rectangle()
                .fill(Color.white)
                .frame(width: 1.5, height: 20)
                .offset(y: -35)
            
            Rectangle()
                .fill(Color.white)
                .frame(width: 1.5, height: 20)
                .offset(y: 35)
            
            Rectangle()
                .fill(Color.white)
                .frame(width: 20, height: 1.5)
                .offset(x: -35)
            
            Rectangle()
                .fill(Color.white)
                .frame(width: 20, height: 1.5)
                .offset(x: 35)
        }
        .scaleEffect(pulse ? 1.1 : 1.0)
        .shadow(color: .black.opacity(0.3), radius: 5)
        .shadow(color: .white.opacity(0.5), radius: 10)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}
