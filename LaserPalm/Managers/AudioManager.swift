//
//  AudioManager.swift
//  LaserPalm
//
//  Created by Elmee on 19/12/2025.
//

import AVFoundation
import AppKit

/// Manages game audio and sound effects
class AudioManager {
    static let shared = AudioManager()
    
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    
    private init() {
        setupAudio()
    }
    
    /// Setup audio session
    private func setupAudio() {
        // macOS doesn't require audio session configuration like iOS
        // Just prepare sound effects
        preloadSounds()
    }
    
    /// Preload sound effects
    private func preloadSounds() {
        // We'll use system sounds for simplicity and reliability
        // No external audio files needed
    }
    
    /// Play hit sound
    func playHitSound() {
        NSSound.beep() // System beep as fallback
        // Could be replaced with custom sound file
    }
    
    /// Play miss sound
    func playMissSound() {
        // Subtle sound for miss
        DispatchQueue.global(qos: .background).async {
            NSSound(named: "Funk")?.play()
        }
    }
    
    /// Play shoot sound
    func playShootSound() {
        DispatchQueue.global(qos: .background).async {
            NSSound(named: "Pop")?.play()
        }
    }
}
