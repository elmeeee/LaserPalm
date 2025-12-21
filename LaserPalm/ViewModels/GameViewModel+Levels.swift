//
//  GameViewModel+Levels.swift
//  LaserPalm
//
//  Created by Elmee on 20/12/2025.
//

import Foundation
import Combine

/// Extension for level-based gameplay
extension GameViewModel {
    
    /// Start game with specific level
    func startGame(level: Level) {
        currentLevel = level
        gameState = .loading
        stats = PlayerStats()
        
        // Play environment ambience
        AudioManager.shared.playEnvironmentAmbience(level.environment)
        
        cameraManager.requestPermission()
    }
    
    /// Spawn enemy based on current level
    func spawnLevelEnemy() {
        guard let level = currentLevel else {
            print("⚠️ No level set, using fallback spawn")
            spawnEnemy()  // Fallback to default
            return
        }
        
        // Random animal from level's animal types
        let animalType = level.animalTypes.randomElement() ?? .sparrow
        print("🎯 Spawning \(animalType.displayName) for level: \(level.name)")
        
        var position: SIMD3<Float>
        var velocity: SIMD3<Float>
        
        // Determine spawn based on animal type
        switch animalType {
        // Small birds - Fly horizontally at mid-height
        case .sparrow, .robin, .finch:
            let fromLeft = Bool.random()
            let yPos = Float.random(in: 0...3)  // Mid-air height
            
            if fromLeft {
                position = SIMD3<Float>(-10, yPos, Float.random(in: -8...(-5)))
                velocity = SIMD3<Float>(Float.random(in: 1.5...2.5), Float.random(in: -0.3...0.3), 0)
            } else {
                position = SIMD3<Float>(10, yPos, Float.random(in: -8...(-5)))
                velocity = SIMD3<Float>(Float.random(in: -2.5...(-1.5)), Float.random(in: -0.3...0.3), 0)
            }
            
        // Medium birds - Fly horizontally at mid-height, slightly faster
        case .parrot, .toucan, .macaw:
            let fromLeft = Bool.random()
            let yPos = Float.random(in: 1...4)  // Mid-air height
            
            if fromLeft {
                position = SIMD3<Float>(-10, yPos, Float.random(in: -8...(-5)))
                velocity = SIMD3<Float>(Float.random(in: 2...3), Float.random(in: -0.4...0.4), 0)
            } else {
                position = SIMD3<Float>(10, yPos, Float.random(in: -8...(-5)))
                velocity = SIMD3<Float>(Float.random(in: -3...(-2)), Float.random(in: -0.4...0.4), 0)
            }
            
        // Ground animals - Run on ground level
        case .lion, .tiger, .bear, .wolf, .fox, .lynx:
            let fromLeft = Bool.random()
            let yPos: Float = -2  // Ground level
            
            if fromLeft {
                position = SIMD3<Float>(-10, yPos, Float.random(in: -8...(-5)))
                velocity = SIMD3<Float>(Float.random(in: 2...3.5), 0, 0)  // Run horizontally on ground
            } else {
                position = SIMD3<Float>(10, yPos, Float.random(in: -8...(-5)))
                velocity = SIMD3<Float>(Float.random(in: -3.5...(-2)), 0, 0)  // Run horizontally on ground
            }
            
        // Flying predators - Soar at high altitude
        case .eagle, .hawk, .falcon:
            let fromLeft = Bool.random()
            let yPos = Float.random(in: 3...6)  // High altitude
            
            if fromLeft {
                position = SIMD3<Float>(-10, yPos, Float.random(in: -8...(-5)))
                velocity = SIMD3<Float>(Float.random(in: 2.5...4), Float.random(in: -0.5...0.5), 0)
            } else {
                position = SIMD3<Float>(10, yPos, Float.random(in: -8...(-5)))
                velocity = SIMD3<Float>(Float.random(in: -4...(-2.5)), Float.random(in: -0.5...0.5), 0)
            }
        }
        
        let enemy = Enemy(animalType: animalType, position: position, velocity: velocity)
        print("   Position: \(position), Velocity: \(velocity)")
        enemies.append(enemy)
    }
    
    /// Check if level is complete
    func checkLevelCompletion() {
        guard let level = currentLevel else { return }
        
        if stats.hits >= level.targetHits {
            completeLevel()
        }
    }
    
    /// Complete current level
    private func completeLevel() {
        guard let level = currentLevel else { return }
        
        gameState = .paused
        
        // Calculate final score with multiplier
        let finalScore = Int(Float(stats.score) * level.pointsMultiplier)
        
        // Save progress
        GameProgress.shared.completeLevel(
            level.id,
            score: finalScore,
            hits: stats.hits,
            misses: stats.misses
        )
        
        // Play completion sound
        AudioManager.shared.playLevelCompleteSound()
        
        // Stop ambience
        AudioManager.shared.stopAmbience()
        
        // Show level complete screen (will be implemented in UI)
        showLevelComplete = true
    }
    
    /// Handle hit with level-specific points
    func handleLevelHit(enemy: Enemy) {
        enemy.destroy()
        
        // Use animal-specific points
        stats.score += enemy.points
        stats.hits += 1
        
        AudioManager.shared.playHitSound()
        
        // Add floating text
        let text = FloatingText(text: "+\(enemy.points)", position: enemy.position)
        floatingTexts.append(text)
        
        // Check level completion
        checkLevelCompletion()
        
        // Spawn replacement
        spawnLevelEnemy()
    }
}
