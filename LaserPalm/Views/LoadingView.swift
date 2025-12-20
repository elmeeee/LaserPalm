//
//  LoadingView.swift
//  LaserPalm
//
//  Created by Elmee on 19/12/2025.
//

import SwiftUI

/// Modern loading screen with sleek design
struct LoadingView: View {
    @ObservedObject var cameraManager: CameraManager
    @State private var pulseScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.3
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        ZStack {
            // Modern gradient background
            LinearGradient(
                colors: [
                    Color(nsColor: .windowBackgroundColor),
                    Color(nsColor: .controlBackgroundColor)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Icon with modern glow effect
                ZStack {
                    // Animated glow rings
                    ForEach(0..<3) { index in
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color(nsColor: .controlAccentColor).opacity(0.3),
                                        Color(nsColor: .controlAccentColor).opacity(0.0)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 2
                            )
                            .frame(width: 180 + CGFloat(index * 30), height: 180 + CGFloat(index * 30))
                            .scaleEffect(pulseScale)
                            .opacity(glowOpacity - Double(index) * 0.1)
                            .rotationEffect(.degrees(rotationAngle + Double(index * 120)))
                    }
                    
                    // Main icon
                    Image("main-icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 158)
                        .shadow(color: Color(nsColor: .controlAccentColor).opacity(0.3), radius: 30, y: 10)
                        .scaleEffect(pulseScale)
                }
                .frame(height: 300)
                
                // Title
                VStack(spacing: 8) {
                    Text("LaserPalm")
                        .font(.system(size: 48, weight: .semibold, design: .default))
                        .foregroundStyle(Color(nsColor: .labelColor))
                    
                    Text("Wildlife Shooting Game")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(Color(nsColor: .secondaryLabelColor))
                        .tracking(1)
                }
                .padding(.bottom, 50)
                
                // Status Section
                VStack(spacing: 20) {
                    if let error = cameraManager.errorMessage {
                        // Error State
                        errorStateView(error: error)
                    } else if cameraManager.permissionGranted == false {
                        // Permission Required
                        permissionRequiredView()
                    } else {
                        // Loading State
                        loadingStateView()
                    }
                }
                .frame(maxWidth: 500)
                
                Spacer()
                
                // Bottom Instructions
                if cameraManager.errorMessage == nil {
                    instructionsView()
                        .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    // MARK: - State Views
    
    private func errorStateView(error: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.red)
                .symbolRenderingMode(.hierarchical)
            
            Text("Camera Error")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color(nsColor: .labelColor))
            
            Text(error)
                .font(.system(size: 14))
                .foregroundStyle(Color(nsColor: .secondaryLabelColor))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: openSystemSettings) {
                HStack(spacing: 8) {
                    Image(systemName: "gear")
                    Text("Open System Settings")
                }
                .font(.system(size: 15, weight: .medium))
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(nsColor: .controlAccentColor))
        }
        .padding(30)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
    
    private func permissionRequiredView() -> some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.orange)
                .symbolRenderingMode(.hierarchical)
            
            Text("Camera Access Required")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color(nsColor: .labelColor))
            
            Text("Please grant camera permission to play")
                .font(.system(size: 14))
                .foregroundStyle(Color(nsColor: .secondaryLabelColor))
            
            Button(action: openSystemSettings) {
                HStack(spacing: 8) {
                    Image(systemName: "gear")
                    Text("Open System Settings")
                }
                .font(.system(size: 15, weight: .medium))
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(nsColor: .controlAccentColor))
        }
        .padding(30)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
    
    private func loadingStateView() -> some View {
        VStack(spacing: 20) {
            // Progress indicator
            ProgressView()
                .scaleEffect(1.2)
                .tint(Color(nsColor: .controlAccentColor))
            
            Text("Initializing Camera & Vision")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color(nsColor: .labelColor))
            
            // Status indicators
            HStack(spacing: 30) {
                StatusIndicator(
                    icon: "checkmark.circle.fill",
                    label: "Permission",
                    isActive: cameraManager.permissionGranted
                )
                
                StatusIndicator(
                    icon: "video.fill",
                    label: "Camera",
                    isActive: cameraManager.isReady
                )
            }
            .padding(.top, 10)
        }
        .padding(30)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
    
    private func instructionsView() -> some View {
        HStack(spacing: 40) {
            InstructionItem(
                icon: "hand.point.up.left.fill",
                text: "Make pistol gesture"
            )
            
            InstructionItem(
                icon: "scope",
                text: "Point to aim"
            )
            
            InstructionItem(
                icon: "hand.tap.fill",
                text: "Thumb to shoot"
            )
        }
        .padding(.horizontal, 40)
    }
    
    // MARK: - Helper Functions
    
    private func startAnimations() {
        // Pulse animation
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            pulseScale = 1.05
        }
        
        // Glow animation
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            glowOpacity = 0.6
        }
        
        // Rotation animation
        withAnimation(.linear(duration: 20.0).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
    }
    
    private func openSystemSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Camera") {
            NSWorkspace.shared.open(url)
        }
    }
}

// MARK: - Supporting Views

struct StatusIndicator: View {
    let icon: String
    let label: String
    let isActive: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(isActive ? Color.green : Color(nsColor: .tertiaryLabelColor))
                .symbolRenderingMode(.hierarchical)
            
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color(nsColor: .secondaryLabelColor))
        }
    }
}

struct InstructionItem: View {
    let icon: String
    let text: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(Color(nsColor: .controlAccentColor))
                .symbolRenderingMode(.hierarchical)
                .frame(height: 30)
            
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color(nsColor: .secondaryLabelColor))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: 120)
    }
}

#Preview {
    LoadingView(cameraManager: CameraManager())
}
