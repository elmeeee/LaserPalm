//
//  GameState.swift
//  LaserPalm
//
//  Created by Elmee on 19/12/2025.
//

import Foundation
import simd

/// Represents the current state of the game
enum GameState {
    case loading
    case ready
    case playing
    case paused
}

/// Represents a hand gesture state
struct HandGesture {
    var isDetected: Bool = false
    var fingerTipPosition: SIMD2<Float> = .zero
    var aimDirection: SIMD3<Float> = SIMD3<Float>(0, 0, -1)
    var isTriggerPulled: Bool = false
    var lastTriggerState: Bool = false
    
    /// Returns true only when trigger transitions from false to true
    var didTrigger: Bool {
        return isTriggerPulled && !lastTriggerState
    }
    
    mutating func updateTriggerState() {
        lastTriggerState = isTriggerPulled
    }
}

/// Represents the player's score and stats
struct PlayerStats {
    var score: Int = 0
    var hits: Int = 0
    var misses: Int = 0
    var accuracy: Float {
        let total = hits + misses
        return total > 0 ? Float(hits) / Float(total) * 100 : 0
    }
}
