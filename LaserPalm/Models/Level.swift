//
//  Level.swift
//  LaserPalm
//
//  Created by Elmee on 20/12/2025.
//

import Foundation
import simd

/// Represents a game level with environment and animals
struct Level: Identifiable, Codable {
    let id: Int
    let name: String
    let environment: GameEnvironment
    let animalTypes: [AnimalType]
    let difficulty: Difficulty
    let targetHits: Int
    let pointsMultiplier: Float
    
    var isUnlocked: Bool {
        return id == 1 || GameProgress.shared.isLevelUnlocked(id)
    }
    
    var stars: Int {
        return GameProgress.shared.getStars(for: id)
    }
}

/// Animal types for different levels
enum AnimalType: String, Codable {
    // Small Birds (Easy)
    case sparrow
    case robin
    case finch
    
    // Medium Birds (Medium)
    case parrot
    case toucan
    case macaw
    
    // Large Animals (Hard)
    case lion
    case tiger
    case bear
    
    // Predators (Very Hard)
    case wolf
    case fox
    case lynx
    
    // Flying Predators (Expert)
    case eagle
    case hawk
    case falcon
    
    var size: Float {
        switch self {
        case .sparrow, .robin, .finch:
            return 0.2  // Reduced from 0.3 - smaller hitbox
        case .parrot, .toucan, .macaw:
            return 0.25  // Reduced from 0.4
        case .wolf, .fox, .lynx:
            return 0.3  // Reduced from 0.5
        case .lion, .tiger, .bear:
            return 0.35  // Reduced from 0.6
        case .eagle, .hawk, .falcon:
            return 0.4  // Reduced from 0.7
        }
    }
    
    var speedMultiplier: Float {
        switch self {
        case .sparrow, .robin, .finch:
            return 1.0  // Slow
        case .parrot, .toucan, .macaw:
            return 1.5  // Medium
        case .lion, .tiger, .bear:
            return 2.0  // Fast
        case .wolf, .fox, .lynx:
            return 2.5  // Very Fast
        case .eagle, .hawk, .falcon:
            return 3.0  // Extreme
        }
    }
    
    var points: Int {
        switch self {
        case .sparrow, .robin, .finch:
            return 100
        case .parrot, .toucan, .macaw:
            return 200
        case .lion, .tiger, .bear:
            return 300
        case .wolf, .fox, .lynx:
            return 500
        case .eagle, .hawk, .falcon:
            return 1000
        }
    }
    
    var displayName: String {
        return rawValue.capitalized
    }
    
    var imageName: String {
        return "enemy_\(rawValue)"
    }
}

/// Difficulty levels
enum Difficulty: String, Codable {
    case easy
    case medium
    case hard
    case veryHard
    case expert
    
    var displayName: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        case .veryHard: return "Very Hard"
        case .expert: return "Expert"
        }
    }
}

/// Level definitions
extension Level {
    static let allLevels: [Level] = [
        Level(
            id: 1,
            name: "Forest",
            environment: .forest,
            animalTypes: [.sparrow, .robin, .finch],
            difficulty: .easy,
            targetHits: 10,
            pointsMultiplier: 1.0
        ),
        Level(
            id: 2,
            name: "Jungle",
            environment: .jungle,
            animalTypes: [.parrot, .toucan, .macaw],
            difficulty: .medium,
            targetHits: 15,
            pointsMultiplier: 1.5
        ),
        Level(
            id: 3,
            name: "Savanna",
            environment: .savanna,
            animalTypes: [.lion, .tiger, .bear],
            difficulty: .hard,
            targetHits: 20,
            pointsMultiplier: 2.0
        ),
        Level(
            id: 4,
            name: "Arctic",
            environment: .arctic,
            animalTypes: [.wolf, .fox, .lynx],
            difficulty: .veryHard,
            targetHits: 25,
            pointsMultiplier: 2.5
        ),
        Level(
            id: 5,
            name: "Mountain",
            environment: .mountain,
            animalTypes: [.eagle, .hawk, .falcon],
            difficulty: .expert,
            targetHits: 30,
            pointsMultiplier: 3.0
        )
    ]
    
    static func getLevel(id: Int) -> Level? {
        return allLevels.first { $0.id == id }
    }
}
