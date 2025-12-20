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
            // Remove default commands for cleaner experience
            CommandGroup(replacing: .newItem) { }
            
            // Add custom menu items
            CommandGroup(after: .appInfo) {
                Button("How to Play") {
                    // Show how to play instructions
                }
                .keyboardShortcut("?", modifiers: .command)
            }
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
                    Label("General", systemImage: "gear")
                }
            
            GameplaySettingsView()
                .tabItem {
                    Label("Gameplay", systemImage: "gamecontroller")
                }
        }
        .frame(width: 450, height: 300)
    }
}

struct GeneralSettingsView: View {
    var body: some View {
        Form {
            Section {
                Text("LaserPalm")
                    .font(.title)
                    .bold()
                Text("Version 1.0")
                    .foregroundColor(.secondary)
                
                Divider()
                
                Text("A gesture-based shooting game for macOS")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}

struct GameplaySettingsView: View {
    @AppStorage("aimAssist") private var aimAssist = true
    @AppStorage("soundEffects") private var soundEffects = true
    
    var body: some View {
        Form {
            Section("Game Settings") {
                Toggle("Magnetic Aim Assist", isOn: $aimAssist)
                Toggle("Sound Effects", isOn: $soundEffects)
            }
        }
        .padding()
    }
}
