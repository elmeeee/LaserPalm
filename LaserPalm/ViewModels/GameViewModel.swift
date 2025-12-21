//
//  GameViewModel.swift
//  LaserPalm
//
//  Created by Elmee on 19/12/2025.
//

import Foundation
import Combine
import SceneKit

/// Main game logic coordinator
class GameViewModel: ObservableObject {
    @Published var gameState: GameState = .menu
    @Published var stats = PlayerStats()
    @Published var enemies: [Enemy] = []
    @Published var floatingTexts: [FloatingText] = []
    @Published var fingerTipPosition: SIMD2<Float> = SIMD2<Float>(0.5, 0.5) // Normalized screen position
    
    
    // Level-based gameplay
    @Published var currentLevel: Level?
    @Published var showLevelComplete: Bool = false
    
    // Improvements
    @Published var comboSystem = ComboSystem()
    @Published var screenShake = ScreenShakeManager()
    
    let cameraManager = CameraManager()
    let visionManager = VisionManager()
    
    private var lastUpdateTime: Date?
    private var cancellables = Set<AnyCancellable>()
    private let maxEnemies = 4
    
    // Aim assist - Temporarily increased for testing
    private let aimAssistRadius: Float = 0.3  // Increased from 0.15 for testing
    private let aimAssistStrength: Float = 0.3  // Increased from 0.1 for testing
    
    // Trigger state tracking
    private var lastTriggerState: Bool = false
    
    init() {
        setupObservers()
    }
    
    /// Setup observers for camera and vision
    private func setupObservers() {
        // Monitor camera readiness
        cameraManager.$isReady
            .sink { [weak self] isReady in
                if isReady {
                    self?.transitionToReady()
                }
            }
            .store(in: &cancellables)
        
        // Monitor hand gestures for shooting
        visionManager.$handGesture
            .sink { [weak self] gesture in
                self?.handleGesture(gesture)
                // Update finger tip position for crosshair
                if gesture.isDetected {
                    self?.fingerTipPosition = gesture.fingerTipPosition
                }
            }
            .store(in: &cancellables)
        
        // Monitor camera frames for vision processing
        cameraManager.$currentFrame
            .compactMap { $0 }
            .sink { [weak self] frame in
                self?.visionManager.processFrame(frame)
            }
            .store(in: &cancellables)
    }
    
    /// Show menu
    func showMenu() {
        gameState = .menu
        cameraManager.stop()
    }
    
    /// Start the game (called from menu)
    func startGame() {
        // Set default level if none selected (Forest - Level 1)
        if currentLevel == nil {
            currentLevel = Level.allLevels.first
        }
        
        gameState = .loading
        cameraManager.requestPermission()
    }
    
    /// Transition to ready state
    private func transitionToReady() {
        DispatchQueue.main.async { [weak self] in
            self?.gameState = .ready
            self?.startPlaying()
        }
    }
    
    /// Start playing
    private func startPlaying() {
        gameState = .playing
        spawnInitialEnemies()
        // Game loop is driven by SceneKit's renderer delegate (GameSceneView.Coordinator)
    }
    
    /// Spawn initial enemies
    private func spawnInitialEnemies() {
        for _ in 0..<maxEnemies {
            spawnLevelEnemy()
        }
    }
    
    /// Spawn a new enemy
    func spawnEnemy() {
        let edge = Int.random(in: 0...3)
        var position: SIMD3<Float>
        var velocity: SIMD3<Float>
        
        switch edge {
        case 0: // Left
            position = SIMD3<Float>(-10, Float.random(in: -3...3), Float.random(in: -8...(-5)))
            velocity = SIMD3<Float>(Float.random(in: 1...2), Float.random(in: -0.5...0.5), Float.random(in: 0.5...1))
        case 1: // Right
            position = SIMD3<Float>(10, Float.random(in: -3...3), Float.random(in: -8...(-5)))
            velocity = SIMD3<Float>(Float.random(in: -2...(-1)), Float.random(in: -0.5...0.5), Float.random(in: 0.5...1))
        case 2: // Top
            position = SIMD3<Float>(Float.random(in: -5...5), 8, Float.random(in: -8...(-5)))
            velocity = SIMD3<Float>(Float.random(in: -0.5...0.5), Float.random(in: -2...(-1)), Float.random(in: 0.5...1))
        default: // Bottom
            position = SIMD3<Float>(Float.random(in: -5...5), -8, Float.random(in: -8...(-5)))
            velocity = SIMD3<Float>(Float.random(in: -0.5...0.5), Float.random(in: 1...2), Float.random(in: 0.5...1))
        }
        
        let enemy = Enemy(position: position, velocity: velocity)
        enemies.append(enemy)
    }
    
    /// Handle hand gesture input
    private func handleGesture(_ gesture: HandGesture) {
        guard gameState == .playing, gesture.isDetected else {
            lastTriggerState = false
            return
        }
        
        // Check for trigger pull (state-based, not continuous)
        // Only shoot when trigger transitions from false to true
        let didTrigger = gesture.isTriggerPulled && !lastTriggerState
        
        if didTrigger {
            shoot(direction: gesture.aimDirection, fingerPosition: gesture.fingerTipPosition)
        }
        
        // Update trigger state for next frame
        lastTriggerState = gesture.isTriggerPulled
    }
    
    /// Shoot in the given direction
    private func shoot(direction: SIMD3<Float>, fingerPosition: SIMD2<Float>) {
        AudioManager.shared.playShootSound()
        
        // Ray origin (camera position)
        let rayOrigin = SIMD3<Float>(0, 0, 0)
        
        // Convert finger position (0-1 normalized) to world direction
        // Map finger position to screen space, then to 3D ray
        // Center of screen is (0.5, 0.5), we need to convert to direction
        let screenX = (fingerPosition.x - 0.5) * 2.0  // -1 to 1
        let screenY = (fingerPosition.y - 0.5) * 2.0  // -1 to 1
        
        // Create ray direction from finger position
        // Adjust FOV and aspect ratio for accurate aiming
        let fov: Float = 60.0 * .pi / 180.0  // 60 degrees FOV
        let aspect: Float = 16.0 / 9.0  // Typical aspect ratio
        
        let rayDir = SIMD3<Float>(
            screenX * tan(fov / 2.0) * aspect,
            -screenY * tan(fov / 2.0),  // Inverted Y
            -1.0  // Looking down -Z axis
        )
        let normalizedRayDir = normalize(rayDir)
        
        // Apply minimal aim assist (optional, very subtle)
        let finalDirection = applyAimAssist(direction: normalizedRayDir)
        
        // Check collision with enemies
        var hitEnemy: Enemy?
        var closestDistance: Float = Float.infinity
        
        for enemy in enemies where enemy.isAlive {
            if enemy.checkCollision(rayOrigin: rayOrigin, rayDirection: finalDirection) {
                let distance = length(enemy.position - rayOrigin)
                if distance < closestDistance {
                    closestDistance = distance
                    hitEnemy = enemy
                }
            }
        }
        
        if let enemy = hitEnemy {
            // Hit!
            handleHit(enemy: enemy)
        } else {
            // Miss
            handleMiss(direction: finalDirection)
        }
    }
    
    /// Apply magnetic aim assist
    private func applyAimAssist(direction: SIMD3<Float>) -> SIMD3<Float> {
        let rayOrigin = SIMD3<Float>(0, 0, 0)
        var closestEnemy: Enemy?
        var closestAngle: Float = Float.infinity
        
        for enemy in enemies where enemy.isAlive {
            let toEnemy = normalize(enemy.position - rayOrigin)
            let angle = acos(dot(direction, toEnemy))
            
            if angle < aimAssistRadius && angle < closestAngle {
                closestAngle = angle
                closestEnemy = enemy
            }
        }
        
        if let enemy = closestEnemy {
            // Gently pull aim toward enemy - Stronger pull for easier hits
            let toEnemy = normalize(enemy.position - rayOrigin)
            let pullStrength = aimAssistStrength
            return normalize(direction * (1.0 - pullStrength) + toEnemy * pullStrength)
        }
        
        return direction
    }
    
    /// Handle successful hit
    private func handleHit(enemy: Enemy) {
        enemy.destroy()
        
        // Add to combo
        comboSystem.addHit()
        
        // Calculate score with multiplier
        let baseScore = 100
        let finalScore = Int(Float(baseScore) * comboSystem.multiplier)
        stats.score += finalScore
        stats.hits += 1
        
        // Screen shake for impact
        screenShake.shake(intensity: 8)
        
        AudioManager.shared.playHitSound()
        
        // Add floating text with combo info
        let text: String
        if comboSystem.currentCombo >= 3 {
            text = "+\(finalScore) \(comboSystem.comboText)"
        } else {
            text = "+\(finalScore)"
        }
        
        let floatingText = FloatingText(text: text, position: enemy.position)
        floatingTexts.append(floatingText)
        
        // Spawn replacement enemy
        spawnLevelEnemy()
    }
    
    /// Handle miss
    private func handleMiss(direction: SIMD3<Float>) {
        stats.misses += 1
        
        // Break combo on miss
        comboSystem.breakCombo()
        
        AudioManager.shared.playMissSound()
        
        // Add floating "MISS" text at ray endpoint
        let missPosition = direction * 5.0
        let text = FloatingText(text: "MISS", position: missPosition)
        floatingTexts.append(text)
    }
    
    /// Game loop update
    func update() {
        guard gameState == .playing else { return }
        
        let now = Date()
        let deltaTime = Float(lastUpdateTime?.distance(to: now) ?? 0.016)
        lastUpdateTime = now
        
        // Update enemies
        for enemy in enemies {
            enemy.update(deltaTime: deltaTime)
        }
        
        // Remove out-of-bounds enemies and spawn replacements
        let beforeCount = enemies.count
        enemies.removeAll { enemy in
            if enemy.isOutOfBounds() || !enemy.isAlive {
                enemy.node?.removeFromParentNode()
                return true
            }
            return false
        }
        
        let removed = beforeCount - enemies.count
        for _ in 0..<removed {
            spawnLevelEnemy()
        }
        
        // Update floating texts
        floatingTexts.removeAll { text in
            !text.update(deltaTime: deltaTime)
        }
    }
    
    /// Get current aim direction with assist visualization
    func getAimDirection() -> SIMD3<Float> {
        return visionManager.handGesture.aimDirection
    }
    
    /// Check if hand is detected
    func isHandDetected() -> Bool {
        return visionManager.handGesture.isDetected
    }
}
