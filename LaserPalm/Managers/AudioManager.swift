//
//  AudioManager.swift
//  LaserPalm
//
//  Created by Elmee on 19/12/2025.
//

import AVFoundation
import AppKit
import Combine

/// Manages game audio and sound effects with environment-specific ambience
class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    @Published var isMuted: Bool = false {
        didSet {
            UserDefaults.standard.set(isMuted, forKey: "audioMuted")
        }
    }
    
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var ambiencePlayer: AVAudioPlayer?
    private var currentEnvironment: GameEnvironment?
    
    private init() {
        setupAudio()
        loadSettings()
    }
    
    /// Setup audio session
    private func setupAudio() {
        preloadSounds()
    }
    
    private func loadSettings() {
        isMuted = UserDefaults.standard.bool(forKey: "audioMuted")
    }
    
    /// Preload sound effects
    private func preloadSounds() {
        // Using system sounds for reliability
        // Custom sounds can be added later
    }
    
    
    /// Play hit sound
    func playHitSound() {
        guard !isMuted else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            NSSound(named: "Hero")?.play()
        }
    }
    
    /// Play miss sound
    func playMissSound() {
        guard !isMuted else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            NSSound(named: "Basso")?.play()
        }
    }
    
    /// Play shoot sound
    func playShootSound() {
        guard !isMuted else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            NSSound(named: "Pop")?.play()
        }
    }
    
    /// Play level complete sound
    func playLevelCompleteSound() {
        guard !isMuted else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            NSSound(named: "Glass")?.play()
        }
    }
    
    /// Play achievement unlocked sound
    func playAchievementSound() {
        guard !isMuted else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            NSSound(named: "Ping")?.play()
        }
    }
    
    
    /// Start playing environment ambience
    func playEnvironmentAmbience(_ environment: GameEnvironment) {
        guard !isMuted else { return }
        guard currentEnvironment != environment else { return }
        
        stopAmbience()
        currentEnvironment = environment
        
        // Play subtle ambience based on environment
        // For now using system sounds, can be replaced with custom audio files
        DispatchQueue.global(qos: .background).async { [weak self] in
            switch environment {
            case .forest:
                // Forest birds chirping
                self?.playLoopingSound(named: "Submarine", volume: 0.3)
            case .jungle:
                // Dense jungle sounds
                self?.playLoopingSound(named: "Submarine", volume: 0.4)
            case .savanna:
                // Wind and distant animals
                self?.playLoopingSound(named: "Blow", volume: 0.2)
            case .arctic:
                // Wind and ice
                self?.playLoopingSound(named: "Blow", volume: 0.3)
            case .mountain:
                // Mountain wind
                self?.playLoopingSound(named: "Blow", volume: 0.25)
            }
        }
    }
    
    private func playLoopingSound(named: String, volume: Float) {
        guard let sound = NSSound(named: named) else { return }
        sound.loops = true
        sound.volume = volume
        sound.play()
    }
    
    /// Stop environment ambience
    func stopAmbience() {
        ambiencePlayer?.stop()
        ambiencePlayer = nil
        currentEnvironment = nil
    }
    
    
    /// Play button click sound
    func playButtonSound() {
        guard !isMuted else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            NSSound(named: "Tink")?.play()
        }
    }
    
    /// Play menu navigation sound
    func playNavigationSound() {
        guard !isMuted else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            NSSound(named: "Pop")?.play()
        }
    }
}
