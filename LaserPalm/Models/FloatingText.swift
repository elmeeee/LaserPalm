//
//  FloatingText.swift
//  LaserPalm
//
//  Created by Elmee on 19/12/2025.
//

import Foundation
import SceneKit

/// Represents floating text VFX (HIT/MISS)
class FloatingText: Identifiable {
    let id = UUID()
    let text: String
    let position: SIMD3<Float>
    var lifetime: Float = 0
    let maxLifetime: Float = 1.5
    var node: SCNNode?
    
    init(text: String, position: SIMD3<Float>) {
        self.text = text
        self.position = position
    }
    
    /// Update floating text animation
    func update(deltaTime: Float) -> Bool {
        lifetime += deltaTime
        
        if let node = node {
            // Float upward
            let progress = lifetime / maxLifetime
            node.position.y = CGFloat(position.y + progress * 2.0)
            
            // Fade out
            node.opacity = CGFloat(1.0 - progress)
        }
        
        return lifetime < maxLifetime
    }
}
