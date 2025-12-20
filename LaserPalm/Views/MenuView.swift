//
//  MenuView.swift
//  LaserPalm
//
//  Created by Elmee on 20/12/2025.
//

import SwiftUI

/// Main menu view
struct MenuView: View {
    @Binding var showMenu: Bool
    @State private var showLeaderboard = false
    @State private var isAnimating = false
    
    var onStartGame: () -> Void
    var onExit: () -> Void
    
    var body: some View {
        ZStack {
            // Animated background
            LinearGradient(
                colors: [.black, .blue.opacity(0.3), .cyan.opacity(0.2), .black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .hueRotation(.degrees(isAnimating ? 45 : 0))
            .animation(.linear(duration: 5).repeatForever(autoreverses: true), value: isAnimating)
            
            VStack(spacing: 40) {
                Spacer()
                
                // Logo & Title
                VStack(spacing: 20) {
                    Image(systemName: "hand.point.up.left.fill")
                        .font(.system(size: 100))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.cyan, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .cyan.opacity(0.5), radius: 20)
                        .rotationEffect(.degrees(isAnimating ? 10 : -10))
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
                    
                    Text("LaserPalm")
                        .font(.system(size: 72, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .cyan],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .cyan.opacity(0.5), radius: 10)
                    
                    Text("Gesture Shooting Game")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Menu Buttons
                VStack(spacing: 20) {
                    // Start Game Button
                    MenuButton(
                        icon: "play.fill",
                        title: "START GAME",
                        color: .cyan
                    ) {
                        onStartGame()
                    }
                    
                    // Leaderboard Button
                    MenuButton(
                        icon: "trophy.fill",
                        title: "LEADERBOARD",
                        color: .orange
                    ) {
                        showLeaderboard = true
                    }
                    
                    // How to Play Button
                    MenuButton(
                        icon: "questionmark.circle.fill",
                        title: "HOW TO PLAY",
                        color: .green
                    ) {
                        // Show tutorial
                    }
                    
                    // Exit Button
                    MenuButton(
                        icon: "xmark.circle.fill",
                        title: "EXIT",
                        color: .red
                    ) {
                        onExit()
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Footer
                Text("Use hand gestures to aim and shoot")
                    .font(.system(size: 14))
                    .foregroundColor(.gray.opacity(0.6))
                    .padding(.bottom, 20)
            }
        }
        .onAppear {
            isAnimating = true
        }
        .sheet(isPresented: $showLeaderboard) {
            LeaderboardView()
        }
    }
}

/// Reusable menu button
struct MenuButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 40)
                
                Text(title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        LinearGradient(
                            colors: isHovered ? [color, color.opacity(0.7)] : [color.opacity(0.8), color.opacity(0.5)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: color.opacity(isHovered ? 0.6 : 0.3), radius: isHovered ? 20 : 10)
            )
            .scaleEffect(isHovered ? 1.05 : 1.0)
            .animation(.spring(response: 0.3), value: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

/// Leaderboard view
struct LeaderboardView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                HStack {
                    Text("🏆 Leaderboard")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                
                // Placeholder
                VStack(spacing: 20) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.orange)
                    
                    Text("Coming Soon!")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Leaderboard will be available in the next update")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .frame(maxHeight: .infinity)
            }
        }
    }
}

#Preview {
    MenuView(showMenu: .constant(true), onStartGame: {}, onExit: {})
}
