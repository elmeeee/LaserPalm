//
//  LoadingView.swift
//  LaserPalm
//
//  Created by Elmee on 19/12/2025.
//

import SwiftUI

/// Loading screen shown during initialization
struct LoadingView: View {
    @ObservedObject var cameraManager: CameraManager
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Dark background
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Animated logo/icon
                Image(systemName: "hand.point.up.left.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.cyan)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: isAnimating)
                
                // Title
                Text("LaserPalm")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                // Loading message
                VStack(spacing: 10) {
                    if let error = cameraManager.errorMessage {
                        // Show error
                        Text("❌ Error")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.red)
                        
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(.red.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Open System Settings") {
                            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Camera") {
                                NSWorkspace.shared.open(url)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.cyan)
                        .padding(.top)
                        
                    } else if cameraManager.permissionGranted == false {
                        // Permission denied
                        Text("Camera Permission Required")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.orange)
                        
                        Text("Please grant camera access in System Settings")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        Button("Open System Settings") {
                            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Camera") {
                                NSWorkspace.shared.open(url)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.cyan)
                        .padding(.top)
                        
                    } else {
                        // Normal loading
                        Text("Initializing Camera & Vision...")
                            .font(.system(size: 18))
                            .foregroundColor(.gray)
                        
                        ProgressView()
                            .progressViewStyle(.circular)
                            .scaleEffect(1.2)
                            .tint(.cyan)
                        
                        // Debug info
                        VStack(spacing: 4) {
                            HStack {
                                Circle()
                                    .fill(cameraManager.permissionGranted ? Color.green : Color.gray)
                                    .frame(width: 8, height: 8)
                                Text("Permission: \(cameraManager.permissionGranted ? "Granted" : "Pending")")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                            
                            HStack {
                                Circle()
                                    .fill(cameraManager.isReady ? Color.green : Color.gray)
                                    .frame(width: 8, height: 8)
                                Text("Camera: \(cameraManager.isReady ? "Ready" : "Initializing")")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.top, 8)
                    }
                }
                
                // Instructions
                VStack(alignment: .leading, spacing: 8) {
                    Text("How to Play:")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    HStack {
                        Image(systemName: "hand.point.up.left")
                        Text("Make a pistol gesture with your hand")
                    }
                    .foregroundColor(.gray)
                    
                    HStack {
                        Image(systemName: "scope")
                        Text("Point your index finger to aim")
                    }
                    .foregroundColor(.gray)
                    
                    HStack {
                        Image(systemName: "hand.tap")
                        Text("Move thumb to trigger to shoot")
                    }
                    .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    LoadingView(cameraManager: CameraManager())
}
