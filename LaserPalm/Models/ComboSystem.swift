//
//  ComboSystem.swift
//  LaserPalm
//
//  Created by Elmee on 21/12/2025.
//

import Foundation
import Combine

/// Combo system for consecutive hits
class ComboSystem: ObservableObject {
    @Published var currentCombo: Int = 0
    @Published var maxCombo: Int = 0
    @Published var multiplier: Float = 1.0
    
    private var comboTimer: Timer?
    private let comboTimeout: TimeInterval = 2.0 // Reset combo after 2 seconds
    
    /// Add a hit to the combo
    func addHit() {
        currentCombo += 1
        
        if currentCombo > maxCombo {
            maxCombo = currentCombo
        }
        
        // Calculate multiplier based on combo
        multiplier = 1.0 + Float(min(currentCombo, 10)) * 0.1 // Max 2x at 10 combo
        
        // Reset timer
        resetTimer()
    }
    
    /// Break the combo (on miss)
    func breakCombo() {
        currentCombo = 0
        multiplier = 1.0
        comboTimer?.invalidate()
        comboTimer = nil
    }
    
    /// Reset the combo timer
    private func resetTimer() {
        comboTimer?.invalidate()
        comboTimer = Timer.scheduledTimer(withTimeInterval: comboTimeout, repeats: false) { [weak self] _ in
            self?.breakCombo()
        }
    }
    
    /// Get combo text for display
    var comboText: String {
        if currentCombo >= 10 {
            return "LEGENDARY x\(currentCombo)!"
        } else if currentCombo >= 5 {
            return "AMAZING x\(currentCombo)!"
        } else if currentCombo >= 3 {
            return "COMBO x\(currentCombo)!"
        }
        return ""
    }
    
    /// Reset all stats
    func reset() {
        currentCombo = 0
        maxCombo = 0
        multiplier = 1.0
        comboTimer?.invalidate()
        comboTimer = nil
    }
}
