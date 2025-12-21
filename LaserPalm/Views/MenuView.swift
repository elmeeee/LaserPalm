//
//  MenuView.swift
//  LaserPalm
//
//  Created by Elmee on 20/12/2025.
//

import SwiftUI

/// Main menu view - Modern Clean Apple Design
struct MenuView: View {
    @Binding var showMenu: Bool
    @State private var showLeaderboard = false
    @State private var showHowToPlay = false
    @State private var showLevels = false
    
    var onStartGame: () -> Void
    var onExit: () -> Void
    
    var body: some View {
        ZStack {
            // Clean gradient background
            LinearGradient(
                colors: [
                    Color(nsColor: .windowBackgroundColor),
                    Color(nsColor: .controlBackgroundColor)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // App Icon & Title
                VStack(spacing: 16) {
                    // App Icon
                    Image("main-icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 112, height: 147)
                        .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
                    
                    // App Name
                    Text("LaserPalm")
                        .font(.system(size: 42, weight: .semibold, design: .default))
                        .foregroundStyle(Color(nsColor: .labelColor))
                    
                    // Subtitle
                    Text("Wildlife Shooting Game")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(Color(nsColor: .secondaryLabelColor))
                }
                .padding(.bottom, 50)
                
                // Menu Buttons
                VStack(spacing: 12) {
                    // New Game - Primary
                    ModernMenuButton(
                        title: "New Game",
                        icon: "play.fill",
                        isPrimary: true
                    ) {
                        onStartGame()
                    }
                    
                    // Levels
                    ModernMenuButton(
                        title: "Levels",
                        icon: "square.grid.2x2.fill",
                        isPrimary: false
                    ) {
                        showLevels = true
                    }
                    
                    // Leaderboard
                    ModernMenuButton(
                        title: "Leaderboard",
                        icon: "trophy.fill",
                        isPrimary: false
                    ) {
                        showLeaderboard = true
                    }
                    
                    // How to Play
                    ModernMenuButton(
                        title: "How to Play",
                        icon: "questionmark.circle.fill",
                        isPrimary: false
                    ) {
                        showHowToPlay = true
                    }
                }
                .frame(maxWidth: 400)
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Footer
                VStack(spacing: 8) {
                    Divider()
                        .padding(.horizontal, 40)
                    
                    Button(action: onExit) {
                        HStack(spacing: 6) {
                            Image(systemName: "power")
                                .font(.system(size: 11, weight: .medium))
                            Text("Quit")
                                .font(.system(size: 13, weight: .regular))
                        }
                        .foregroundStyle(Color(nsColor: .secondaryLabelColor))
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 16)
                }
            }
        }
        .sheet(isPresented: $showLeaderboard) {
            ModernLeaderboardView()
        }
        .sheet(isPresented: $showHowToPlay) {
            ModernHowToPlayView()
        }
        .sheet(isPresented: $showLevels) {
            ModernLevelsView()
        }
    }
}

/// Modern menu button - Clean Apple style
struct ModernMenuButton: View {
    let title: String
    let icon: String
    let isPrimary: Bool
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
                
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .opacity(0.5)
            }
            .foregroundStyle(isPrimary ? .white : Color(nsColor: .labelColor))
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isPrimary ? Color(nsColor: .controlAccentColor) : Color(nsColor: .controlBackgroundColor))
                    .shadow(color: .black.opacity(isHovered ? 0.15 : 0.08), radius: isHovered ? 12 : 8, y: isHovered ? 6 : 4)
            )
            .scaleEffect(isHovered ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}

/// Modern Levels View
struct ModernLevelsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var progress = GameProgress.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 17, weight: .regular))
                    }
                    .foregroundStyle(Color(nsColor: .controlAccentColor))
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Text("Levels")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color(nsColor: .labelColor))
                
                Spacer()
                
                // Total Score
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Total")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color(nsColor: .secondaryLabelColor))
                    Text("\(progress.totalScore)")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color(nsColor: .labelColor))
                }
            }
            .padding()
            .background(Color(nsColor: .windowBackgroundColor))
            
            Divider()
            
            // Content
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 16) {
                    ForEach(Level.allLevels) { level in
                        LevelCard(level: level)
                    }
                }
                .padding(20)
            }
            .background(Color(nsColor: .controlBackgroundColor))
        }
        .frame(width: 700, height: 600)
    }
}

/// Level Card Component
struct LevelCard: View {
    let level: Level
    @ObservedObject var progress = GameProgress.shared
    @State private var isHovered = false
    
    var body: some View {
        Button(action: {
            if level.isUnlocked {
                // Start level - will be connected to GameViewModel
            }
        }) {
            VStack(spacing: 12) {
                // Icon
                Text(level.environment.emoji)
                    .font(.system(size: 48))
                
                // Name
                Text(level.name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color(nsColor: .labelColor))
                
                // Subtitle
                Text(level.environment.subtitle)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color(nsColor: .secondaryLabelColor))
                
                // Difficulty
                Text(level.difficulty.displayName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color(nsColor: .tertiaryLabelColor))
                
                // Stars or Lock
                if level.isUnlocked {
                    HStack(spacing: 4) {
                        ForEach(0..<3) { index in
                            Image(systemName: index < level.stars ? "star.fill" : "star")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.yellow)
                        }
                    }
                    
                    // Best Score
                    if let levelScore = progress.levelScores[level.id] {
                        Text("\(levelScore.bestScore) pts")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color(nsColor: .secondaryLabelColor))
                    }
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(nsColor: .tertiaryLabelColor))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(nsColor: .controlBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(
                                level.isUnlocked ? Color(nsColor: .controlAccentColor).opacity(0.3) : Color(nsColor: .separatorColor),
                                lineWidth: level.isUnlocked ? 1.5 : 0.5
                            )
                    )
                    .shadow(color: .black.opacity(isHovered ? 0.1 : 0.05), radius: isHovered ? 10 : 5, y: isHovered ? 5 : 2)
            )
            .scaleEffect(isHovered ? 1.03 : 1.0)
            .opacity(level.isUnlocked ? 1.0 : 0.6)
        }
        .buttonStyle(.plain)
        .disabled(!level.isUnlocked)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}

/// Modern Leaderboard View
struct ModernLeaderboardView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 17, weight: .regular))
                    }
                    .foregroundStyle(Color(nsColor: .controlAccentColor))
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Text("Leaderboard")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color(nsColor: .labelColor))
                
                Spacer()
            }
            .padding(.all, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(nsColor: .windowBackgroundColor))
            
            Divider()
            
            // Content
            VStack(spacing: 20) {
                Spacer()
                
                Image(systemName: "trophy.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Color(nsColor: .controlAccentColor))
                    .symbolRenderingMode(.hierarchical)
                
                Text("Coming Soon")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color(nsColor: .labelColor))
                
                Text("Leaderboard will be available in a future update")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(nsColor: .secondaryLabelColor))
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(nsColor: .controlBackgroundColor))
        }
        .frame(width: 500, height: 400)
    }
}

/// Modern How to Play View
struct ModernHowToPlayView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 17, weight: .regular))
                    }
                    .foregroundStyle(Color(nsColor: .controlAccentColor))
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Text("How to Play")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color(nsColor: .labelColor))
                Spacer()
            }
            .padding(.all, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(nsColor: .windowBackgroundColor))
            
            Divider()
            
            // Content - Compact layout
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    ModernInstructionCard(
                        icon: "hand.point.up.left.fill",
                        title: "Make the Pistol Gesture",
                        description: "Extend your index finger and keep other fingers curled. This is your aiming direction."
                    )
                    
                    ModernInstructionCard(
                        icon: "scope",
                        title: "Aim at Targets",
                        description: "Point your index finger at the animals. The crosshair shows your aim direction."
                    )
                    
                    ModernInstructionCard(
                        icon: "hand.tap.fill",
                        title: "Shoot",
                        description: "Move your thumb toward your index finger to trigger a shot."
                    )
                    
                    ModernInstructionCard(
                        icon: "star.fill",
                        title: "Score Points",
                        description: "Hit targets to score points. Complete levels to unlock new environments!"
                    )
                    
                    ModernInstructionCard(
                        icon: "target",
                        title: "Hit Accuracy",
                        description: "Aim carefully! Your accuracy affects your star rating at the end of each level."
                    )
                    
                    ModernInstructionCard(
                        icon: "trophy.fill",
                        title: "Unlock Levels",
                        description: "Complete levels to unlock new environments with different animals and challenges."
                    )
                }
                .padding(18)
            }
            .background(Color(nsColor: .controlBackgroundColor))
        }
        .frame(width: 600, height: 580)
    }
}

/// Modern instruction card
struct ModernInstructionCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 26))
                .foregroundStyle(Color(nsColor: .controlAccentColor))
                .symbolRenderingMode(.hierarchical)
                .frame(width: 36)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(nsColor: .labelColor))
                
                Text(description)
                    .font(.system(size: 12))
                    .foregroundStyle(Color(nsColor: .secondaryLabelColor))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Color(nsColor: .separatorColor), lineWidth: 0.5)
                )
        )
    }
}
