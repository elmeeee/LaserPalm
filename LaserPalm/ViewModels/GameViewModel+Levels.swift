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
            spawnEnemy()  // Fallback to default
            return
        }
        
        // Random animal from level's animal types
        let animalType = level.animalTypes.randomElement() ?? .sparrow
        
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
        
        let enemy = Enemy(animalType: animalType, position: position, velocity: velocity)
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
