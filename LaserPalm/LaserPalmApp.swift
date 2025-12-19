//
//  LaserPalmApp.swift
//  LaserPalm
//
//  Created by Elmee on 19/12/2025.
//

import SwiftUI

@main
struct LaserPalmApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 1024, minHeight: 768)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            // Remove default commands for cleaner experience
            CommandGroup(replacing: .newItem) { }
        }
    }
}
