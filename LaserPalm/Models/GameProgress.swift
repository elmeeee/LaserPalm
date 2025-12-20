//
//  GameProgress.swift
//  LaserPalm
//
//  Created by Elmee on 20/12/2025.
//

import Foundation
import Combine

/// Manages game progression, unlocks, and achievements
class GameProgress: ObservableObject {
    static let shared = GameProgress()
    
    @Published var currentLevel: Int = 1
    @Published var unlockedLevels: Set<Int> = [1]  // Level 1 always unlocked
    @Published var levelScores: [Int: LevelScore] = [:]
    @Published var totalScore: Int = 0
    @Published var achievements: Set<Achievement> = []
    
    private let userDefaults = UserDefaults.standard
    private let progressKey = "gameProgress"
    
    struct LevelScore: Codable {
        var bestScore: Int
        var stars: Int
        var completed: Bool
        var hits: Int
        var misses: Int
        var accuracy: Float
    }
    
    private init() {
        loadProgress()
    }
    
    // MARK: - Level Management
    
    func isLevelUnlocked(_ levelId: Int) -> Bool {
        return unlockedLevels.contains(levelId)
    }
    
    func unlockLevel(_ levelId: Int) {
        unlockedLevels.insert(levelId)
        saveProgress()
    }
    
    func getStars(for levelId: Int) -> Int {
        return levelScores[levelId]?.stars ?? 0
    }
    
    func completeLevel(_ levelId: Int, score: Int, hits: Int, misses: Int) {
        let accuracy = Float(hits) / Float(hits + misses) * 100
        let stars = calculateStars(accuracy: accuracy, hits: hits, level: levelId)
        
        let levelScore = LevelScore(
            bestScore: score,
            stars: stars,
            completed: true,
            hits: hits,
            misses: misses,
            accuracy: accuracy
        )
        
        // Update or create level score
        if let existing = levelScores[levelId] {
            if score > existing.bestScore {
                levelScores[levelId] = levelScore
            }
            if stars > existing.stars {
                levelScores[levelId]?.stars = stars
            }
        } else {
            levelScores[levelId] = levelScore
        }
        
        // Unlock next level
        if levelId < Level.allLevels.count {
            unlockLevel(levelId + 1)
        }
        
        // Update total score
        totalScore = levelScores.values.reduce(0) { $0 + $1.bestScore }
        
        // Check achievements
        checkAchievements()
        
        saveProgress()
    }
    
    private func calculateStars(accuracy: Float, hits: Int, level: Int) -> Int {
        guard let levelData = Level.getLevel(id: level) else { return 0 }
        
        if hits >= levelData.targetHits && accuracy >= 80 {
            return 3
        } else if hits >= levelData.targetHits * 2/3 && accuracy >= 60 {
            return 2
        } else if hits >= levelData.targetHits / 2 {
            return 1
        }
        return 0
    }
    
    // MARK: - Achievements
    
    func checkAchievements() {
        // First Blood
        if levelScores.values.contains(where: { $0.hits > 0 }) {
            unlockAchievement(.firstBlood)
        }
        
        // Sharpshooter
        if levelScores.values.contains(where: { $0.accuracy >= 90 }) {
            unlockAchievement(.sharpshooter)
        }
        
        // Perfect Score
        if levelScores.values.contains(where: { $0.accuracy == 100 }) {
            unlockAchievement(.perfectScore)
        }
        
        // Level Master
        if levelScores.values.filter({ $0.stars == 3 }).count >= 3 {
            unlockAchievement(.levelMaster)
        }
        
        // Completionist
        if levelScores.count == Level.allLevels.count && levelScores.values.allSatisfy({ $0.completed }) {
            unlockAchievement(.completionist)
        }
        
        // High Scorer
        if totalScore >= 10000 {
            unlockAchievement(.highScorer)
        }
    }
    
    func unlockAchievement(_ achievement: Achievement) {
        if !achievements.contains(achievement) {
            achievements.insert(achievement)
            saveProgress()
            // Could show notification here
        }
    }
    
    // MARK: - Persistence
    
    private func saveProgress() {
        let data = ProgressData(
            currentLevel: currentLevel,
            unlockedLevels: Array(unlockedLevels),
            levelScores: levelScores,
            totalScore: totalScore,
            achievements: Array(achievements)
        )
        
        if let encoded = try? JSONEncoder().encode(data) {
            userDefaults.set(encoded, forKey: progressKey)
        }
    }
    
    private func loadProgress() {
        guard let data = userDefaults.data(forKey: progressKey),
              let decoded = try? JSONDecoder().decode(ProgressData.self, from: data) else {
            return
        }
        
        currentLevel = decoded.currentLevel
        unlockedLevels = Set(decoded.unlockedLevels)
        levelScores = decoded.levelScores
        totalScore = decoded.totalScore
        achievements = Set(decoded.achievements)
    }
    
    func resetProgress() {
        currentLevel = 1
        unlockedLevels = [1]
        levelScores = [:]
        totalScore = 0
        achievements = []
        saveProgress()
    }
    
    private struct ProgressData: Codable {
        let currentLevel: Int
        let unlockedLevels: [Int]
        let levelScores: [Int: LevelScore]
        let totalScore: Int
        let achievements: [Achievement]
    }
}

/// Achievement definitions
enum Achievement: String, Codable, CaseIterable {
    case firstBlood = "first_blood"
    case sharpshooter = "sharpshooter"
    case perfectScore = "perfect_score"
    case levelMaster = "level_master"
    case completionist = "completionist"
    case highScorer = "high_scorer"
    
    var title: String {
        switch self {
        case .firstBlood: return "First Blood"
        case .sharpshooter: return "Sharpshooter"
        case .perfectScore: return "Perfect Score"
        case .levelMaster: return "Level Master"
        case .completionist: return "Completionist"
        case .highScorer: return "High Scorer"
        }
    }
    
    var description: String {
        switch self {
        case .firstBlood: return "Hit your first target"
        case .sharpshooter: return "Achieve 90% accuracy in a level"
        case .perfectScore: return "Complete a level with 100% accuracy"
        case .levelMaster: return "Get 3 stars on 3 levels"
        case .completionist: return "Complete all levels"
        case .highScorer: return "Reach 10,000 total points"
        }
    }
    
    var icon: String {
        switch self {
        case .firstBlood: return "target"
        case .sharpshooter: return "scope"
        case .perfectScore: return "star.fill"
        case .levelMaster: return "crown.fill"
        case .completionist: return "checkmark.seal.fill"
        case .highScorer: return "trophy.fill"
        }
    }
}
