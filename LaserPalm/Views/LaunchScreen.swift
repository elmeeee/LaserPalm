//
//  LaunchScreen.swift
//  LaserPalm
//
//  Created by Elmee on 20/12/2025.
//

import SwiftUI

/// Launch screen with app branding
struct LaunchScreen: View {
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var glowIntensity: Double = 0
    
    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.15, blue: 0.2),
                    Color(red: 0.05, green: 0.1, blue: 0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // App Icon with Glow
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(nsColor: .controlAccentColor).opacity(glowIntensity * 0.3),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .blur(radius: 20)
                    
                    // Main Icon
                    Image("main-icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140, height: 184)
                        .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
                
                // App Name
                VStack(spacing: 8) {
                    Text("LaserPalm")
                        .font(.system(size: 48, weight: .bold, design: .default))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, Color(nsColor: .controlAccentColor)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Wildlife Shooting Game")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.7))
                        .tracking(2)
                }
                .opacity(textOpacity)
                
                Spacer()
                
                // Loading Indicator
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(.white)
                    
                    Text("Loading...")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.5))
                }
                .opacity(textOpacity)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            // Animate logo
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            
            // Animate text
            withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                textOpacity = 1.0
            }
            
            // Pulsing glow
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                glowIntensity = 1.0
            }
        }
    }
}

#Preview {
    LaunchScreen()
}
