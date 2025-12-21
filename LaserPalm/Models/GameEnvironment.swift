//
//  GameEnvironment.swift
//  LaserPalm
//
//  Created by Elmee on 20/12/2025.
//

import SwiftUI

/// Game Environment with backgrounds and metadata
enum GameEnvironment: String, Codable {
    case forest
    case jungle
    case savanna
    case arctic
    case mountain
    
    var name: String {
        return rawValue.capitalized
    }
    
    var icon: String {
        switch self {
        case .forest: return "tree.fill"
        case .jungle: return "leaf.fill"
        case .savanna: return "sun.max.fill"
        case .arctic: return "snowflake"
        case .mountain: return "mountain.2.fill"
        }
    }
    
    var emoji: String {
        switch self {
        case .forest: return "🌲"
        case .jungle: return "🌴"
        case .savanna: return "🦁"
        case .arctic: return "❄️"
        case .mountain: return "🏔️"
        }
    }
    
    var subtitle: String {
        switch self {
        case .forest: return "Birds"
        case .jungle: return "Parrots"
        case .savanna: return "Lions"
        case .arctic: return "Wolves"
        case .mountain: return "Eagles"
        }
    }
    
    var backgroundImageName: String {
        return "bg_\(rawValue)"
    }
    
    var background: LinearGradient {
        switch self {
        case .forest:
            return LinearGradient(
                colors: [
                    Color(red: 0.6, green: 0.8, blue: 0.5),
                    Color(red: 0.3, green: 0.5, blue: 0.2)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .jungle:
            return LinearGradient(
                colors: [
                    Color(red: 0.2, green: 0.4, blue: 0.2),
                    Color(red: 0.1, green: 0.2, blue: 0.1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .savanna:
            return LinearGradient(
                colors: [
                    Color(red: 0.9, green: 0.7, blue: 0.4),
                    Color(red: 0.7, green: 0.5, blue: 0.2)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .arctic:
            return LinearGradient(
                colors: [
                    Color(red: 0.9, green: 0.95, blue: 1.0),
                    Color(red: 0.7, green: 0.85, blue: 0.95)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .mountain:
            return LinearGradient(
                colors: [
                    Color(red: 0.6, green: 0.65, blue: 0.7),
                    Color(red: 0.4, green: 0.45, blue: 0.5)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}
