//
//  MenuView.swift
//  LaserPalm
//
//  Created by Elmee on 20/12/2025.
//

import SwiftUI

/// Main menu view - Duck Hunt / Retro Arcade Style
struct MenuView: View {
    @Binding var showMenu: Bool
    @State private var showLeaderboard = false
    @State private var showHowToPlay = false
    @State private var blinkOn = true
    @State private var cursorBlink = true
    
    var onStartGame: () -> Void
    var onExit: () -> Void
    
    var body: some View {
        ZStack {
            // Retro sky blue background (Duck Hunt style)
            Color(red: 0.4, green: 0.7, blue: 1.0)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 80)
                
                // Retro Title
                VStack(spacing: 8) {
                    Text("LASERPALM")
                        .font(.system(size: 64, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 0, x: 4, y: 4)
                    
                    Text("GESTURE SHOOTING GAME")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .tracking(2)
                }
                .padding(.bottom, 60)
                
                // Retro Menu Box
                VStack(spacing: 0) {
                    // Menu Items
                    VStack(spacing: 16) {
                        RetroMenuItem(
                            text: "START GAME",
                            icon: "▶",
                            action: onStartGame
                        )
                        
                        RetroMenuItem(
                            text: "LEADERBOARD",
                            icon: "★",
                            action: { showLeaderboard = true }
                        )
                        
                        RetroMenuItem(
                            text: "HOW TO PLAY",
                            icon: "?",
                            action: { showHowToPlay = true }
                        )
                        
                        RetroMenuItem(
                            text: "QUIT",
                            icon: "✕",
                            action: onExit
                        )
                    }
                    .padding(32)
                    .background(
                        RoundedRectangle(cornerRadius: 0)
                            .fill(Color.black.opacity(0.8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 0)
                                    .strokeBorder(Color.white, lineWidth: 4)
                            )
                    )
                }
                .frame(maxWidth: 500)
                
                Spacer()
                
                // Retro Footer
                VStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Text("PRESS")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                        Text(cursorBlink ? "█" : " ")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                        Text("TO SELECT")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                    }
                    .foregroundColor(.white)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.5).repeatForever()) {
                            cursorBlink.toggle()
                        }
                    }
                    
                    Text("© 2025 KAMY GAMES")
                        .font(.system(size: 10, weight: .regular, design: .monospaced))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.bottom, 24)
            }
        }
        .sheet(isPresented: $showLeaderboard) {
            RetroLeaderboardView()
        }
        .sheet(isPresented: $showHowToPlay) {
            RetroHowToPlayView()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever()) {
                blinkOn.toggle()
            }
        }
    }
}

/// Retro menu item - Duck Hunt style
struct RetroMenuItem: View {
    let text: String
    let icon: String
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Text(icon)
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(isHovered ? .black : .white)
                    .frame(width: 32)
                
                Text(text)
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(isHovered ? .black : .white)
                    .tracking(1)
                
                Spacer()
                
                Text(isHovered ? "►" : " ")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 0)
                    .fill(isHovered ? Color.white : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.1)) {
                isHovered = hovering
            }
        }
    }
}

/// Retro Leaderboard View
struct RetroLeaderboardView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(red: 0.4, green: 0.7, blue: 1.0)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("★ LEADERBOARD ★")
                        .font(.system(size: 24, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 0, x: 2, y: 2)
                    
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Text("✕")
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                
                // Content Box
                VStack(spacing: 24) {
                    Spacer()
                    
                    Text("★")
                        .font(.system(size: 80, weight: .bold, design: .monospaced))
                        .foregroundColor(.yellow)
                        .shadow(color: .black, radius: 0, x: 3, y: 3)
                    
                    Text("COMING SOON!")
                        .font(.system(size: 28, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 0, x: 2, y: 2)
                    
                    Text("LEADERBOARD WILL BE")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    Text("AVAILABLE IN NEXT UPDATE")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color.black.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 0)
                                .strokeBorder(Color.white, lineWidth: 4)
                        )
                )
                .padding()
            }
        }
        .frame(width: 600, height: 500)
    }
}

/// Retro How to Play View
struct RetroHowToPlayView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(red: 0.4, green: 0.7, blue: 1.0)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("? HOW TO PLAY ?")
                        .font(.system(size: 24, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 0, x: 2, y: 2)
                    
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Text("✕")
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                
                // Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        RetroInstructionItem(
                            number: "1",
                            title: "MAKE PISTOL GESTURE",
                            description: "EXTEND INDEX FINGER\nKEEP OTHER FINGERS CURLED"
                        )
                        
                        RetroInstructionItem(
                            number: "2",
                            title: "AIM AT TARGETS",
                            description: "POINT YOUR FINGER\nLASER SHOWS AIM DIRECTION"
                        )
                        
                        RetroInstructionItem(
                            number: "3",
                            title: "SHOOT!",
                            description: "MOVE THUMB TO INDEX FINGER\nEACH SHOT NEEDS NEW TRIGGER"
                        )
                        
                        RetroInstructionItem(
                            number: "4",
                            title: "SCORE POINTS",
                            description: "HIT TARGETS = +100 POINTS\nTRACK YOUR ACCURACY!"
                        )
                    }
                    .padding(24)
                }
                .background(
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color.black.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 0)
                                .strokeBorder(Color.white, lineWidth: 4)
                        )
                )
                .padding()
            }
        }
        .frame(width: 700, height: 600)
    }
}

/// Retro instruction item
struct RetroInstructionItem: View {
    let number: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Number badge
            Text(number)
                .font(.system(size: 32, weight: .black, design: .monospaced))
                .foregroundColor(.black)
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(Color.white)
                )
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 16, weight: .black, design: .monospaced))
                    .foregroundColor(.yellow)
                    .shadow(color: .black, radius: 0, x: 1, y: 1)
                
                Text(description)
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .lineSpacing(4)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 0)
                        .strokeBorder(Color.white.opacity(0.3), lineWidth: 2)
                )
        )
    }
}

#Preview {
    MenuView(showMenu: .constant(true), onStartGame: {}, onExit: {})
}
