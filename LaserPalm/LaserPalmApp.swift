//
//  LaserPalmApp.swift
//  LaserPalm
//
//  Created by Elmee on 19/12/2025.
//

import SwiftUI

@main
struct LaserPalmApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 1024, minHeight: 768)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            // Replace default About with custom About window
            CommandGroup(replacing: .appInfo) {
                Button("About LaserPalm") {
                    NSApplication.shared.orderFrontStandardAboutPanel(
                        options: [
                            NSApplication.AboutPanelOptionKey.credits: NSAttributedString(
                                string: """
                                LaserPalm - Wildlife Shooting Game
                                
                                An innovative gesture-based shooting game for macOS that uses your Mac's camera to detect hand gestures.
                                
                                FEATURES:
                                • Hand Gesture Recognition
                                • Real-time Camera Tracking
                                • 5 Unique Environments
                                • 15 Different Animal Types
                                • Skill-based Aiming System
                                • Immersive Sound Effects
                                
                                TECHNOLOGY:
                                • Built with SwiftUI & SceneKit
                                • Vision Framework for hand pose detection
                                • AVFoundation for camera capture
                                • 100% local processing - no data sent
                                
                                HOW TO PLAY:
                                1. Make a finger gun gesture 👉
                                2. Point at targets on screen
                                3. Pinch thumb to index finger to shoot
                                4. Track moving animals with your hand
                                
                                PRIVACY:
                                LaserPalm processes your camera feed locally on your Mac. No video or images are stored, transmitted, or shared.
                                
                                Developed by Kamy
                                © 2025 Kamy. All rights reserved.
                                """,
                                attributes: [
                                    NSAttributedString.Key.font: NSFont.systemFont(ofSize: 11),
                                    NSAttributedString.Key.foregroundColor: NSColor.secondaryLabelColor
                                ]
                            ),
                            NSApplication.AboutPanelOptionKey(rawValue: "Copyright"): "© 2025 Kamy. All rights reserved."
                        ]
                    )
                }
            }
            
            // Remove default commands for cleaner experience
            CommandGroup(replacing: .newItem) { }
            
            // Add custom menu items
        }
        
        Settings {
            SettingsView()
        }
    }
}

// App Delegate for additional macOS integration
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Configure app appearance
        NSApp.appearance = NSAppearance(named: .darkAqua)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

// Settings View
struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gearshape.fill")
                }
            
            GameplaySettingsView()
                .tabItem {
                    Label("Gameplay", systemImage: "gamecontroller.fill")
                }
        }
        .frame(width: 600, height: 500)
    }
}

struct GeneralSettingsView: View {
    var body: some View {
        VStack(spacing: 0) {
            // Header with App Icon and Info
            VStack(spacing: 16) {
                Image("main-icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                
                VStack(spacing: 4) {
                    Text("LaserPalm")
                        .font(.system(size: 32, weight: .bold))
                    
                    Text("Version 1.0")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Text("Wildlife Shooting Game")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 40)
            .padding(.bottom, 30)
            
            Spacer()
            
            // Footer
            VStack(spacing: 8) {
                Text("Developed by Kamy")
                    .font(.callout)
                    .foregroundColor(.secondary)
                
                Text("© 2025 Kamy. All rights reserved.")
                    .font(.caption)
                    .foregroundColor(.secondary.opacity(0.7))
            }
            .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


struct GameplaySettingsView: View {
    @AppStorage("aimAssist") private var aimAssist = true
    @AppStorage("soundEffects") private var soundEffects = true
    @AppStorage("musicEnabled") private var musicEnabled = true
    
    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 20) {
                    // Aim Assist
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle("Magnetic Aim Assist", isOn: $aimAssist)
                            .toggleStyle(.switch)
                            .font(.headline)
                        
                        Text("Helps guide your aim towards targets. Disable for maximum challenge.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Divider()
                    
                    // Sound Effects
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle("Sound Effects", isOn: $soundEffects)
                            .toggleStyle(.switch)
                            .font(.headline)
                        
                        Text("Play sound effects for shooting, hits, and misses.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    // Background Music
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle("Background Music", isOn: $musicEnabled)
                            .toggleStyle(.switch)
                            .font(.headline)
                        
                        Text("Play ambient music and environment sounds during gameplay.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            } header: {
                Text("Game Settings")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .textCase(nil)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}
