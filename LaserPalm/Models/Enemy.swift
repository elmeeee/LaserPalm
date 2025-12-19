//
//  Enemy.swift
//  LaserPalm
//
//  Created by Elmee on 19/12/2025.
//

import Foundation
import SceneKit
import simd

/// Represents a flying disc enemy target
class Enemy: Identifiable {
    let id = UUID()
    var position: SIMD3<Float>
    var velocity: SIMD3<Float>
    var radius: Float = 0.3
    var isAlive: Bool = true
    var node: SCNNode?
    
    init(position: SIMD3<Float>, velocity: SIMD3<Float>) {
        self.position = position
        self.velocity = velocity
    }
    
    /// Update enemy position based on delta time
    func update(deltaTime: Float) {
        guard isAlive else { return }
        position += velocity * deltaTime
        
        // Update SceneKit node position
        node?.position = SCNVector3(position.x, position.y, position.z)
    }
    
    /// Check if enemy is out of bounds and should be removed
    func isOutOfBounds() -> Bool {
        return abs(position.x) > 15 || abs(position.y) > 15 || position.z > 5 || position.z < -15
    }
    
    /// Check collision with a ray
    func checkCollision(rayOrigin: SIMD3<Float>, rayDirection: SIMD3<Float>) -> Bool {
        guard isAlive else { return false }
        
        // Ray-sphere intersection test
        let oc = rayOrigin - position
        let a = dot(rayDirection, rayDirection)
        let b = 2.0 * dot(oc, rayDirection)
        let c = dot(oc, oc) - radius * radius
        let discriminant = b * b - 4 * a * c
        
        return discriminant >= 0
    }
    
    /// Destroy the enemy
    func destroy() {
        isAlive = false
    }
}
