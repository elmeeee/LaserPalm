//
//  GameSceneView.swift
//  LaserPalm
//
//  Created by Elmee on 19/12/2025.
//

import SwiftUI
import SceneKit

/// SceneKit view for 3D game rendering
struct GameSceneView: NSViewRepresentable {
    @ObservedObject var viewModel: GameViewModel
    
    func makeNSView(context: Context) -> SCNView {
        let sceneView = SCNView()
        
        // Create scene
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.backgroundColor = .black
        sceneView.autoenablesDefaultLighting = true
        sceneView.allowsCameraControl = false
        
        // Setup camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, 0)
        scene.rootNode.addChildNode(cameraNode)
        
        // Add ambient light
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.color = NSColor(white: 0.3, alpha: 1.0)
        scene.rootNode.addChildNode(ambientLight)
        
        // Add directional light
        let directionalLight = SCNNode()
        directionalLight.light = SCNLight()
        directionalLight.light?.type = .directional
        directionalLight.light?.color = NSColor.white
        directionalLight.position = SCNVector3(0, 10, 10)
        directionalLight.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(directionalLight)
        
        // Add laser line node
        let laserNode = createLaserNode()
        laserNode.name = "laser"
        laserNode.isHidden = true
        scene.rootNode.addChildNode(laserNode)
        
        // Store context
        context.coordinator.sceneView = sceneView
        context.coordinator.scene = scene
        
        // Start render loop
        sceneView.delegate = context.coordinator
        sceneView.isPlaying = true
        sceneView.preferredFramesPerSecond = 60
        
        return sceneView
    }
    
    func updateNSView(_ nsView: SCNView, context: Context) {
        // Updates are handled in coordinator
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }
    
    /// Create laser aiming line
    private func createLaserNode() -> SCNNode {
        let cylinder = SCNCylinder(radius: 0.01, height: 20)
        cylinder.firstMaterial?.diffuse.contents = NSColor.cyan
        cylinder.firstMaterial?.emission.contents = NSColor.cyan
        
        let node = SCNNode(geometry: cylinder)
        node.opacity = 0.6
        return node
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, SCNSceneRendererDelegate {
        var viewModel: GameViewModel
        weak var sceneView: SCNView?
        weak var scene: SCNScene?
        
        private var enemyNodes: [UUID: SCNNode] = [:]
        private var textNodes: [UUID: SCNNode] = [:]
        
        init(viewModel: GameViewModel) {
            self.viewModel = viewModel
        }
        
        func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
            // Update game logic
            DispatchQueue.main.async { [weak self] in
                self?.viewModel.update()
            }
            
            // Update visuals
            updateEnemies()
            updateLaser()
            updateFloatingTexts()
        }
        
        /// Update enemy nodes
        private func updateEnemies() {
            guard let scene = scene else { return }
            
            // Add/update enemy nodes
            for enemy in viewModel.enemies {
                if let node = enemyNodes[enemy.id] {
                    // Update existing node
                    enemy.node = node
                } else {
                    // Create new node with animal type
                    let node = createEnemyNode(for: enemy.animalType)
                    node.position = SCNVector3(enemy.position.x, enemy.position.y, enemy.position.z)
                    scene.rootNode.addChildNode(node)
                    enemyNodes[enemy.id] = node
                    enemy.node = node
                }
                
                // Handle destruction
                if !enemy.isAlive {
                    if let node = enemyNodes[enemy.id] {
                        // Destruction animation
                        let scaleAction = SCNAction.scale(to: 0.01, duration: 0.2)
                        let fadeAction = SCNAction.fadeOut(duration: 0.2)
                        let group = SCNAction.group([scaleAction, fadeAction])
                        let remove = SCNAction.removeFromParentNode()
                        node.runAction(SCNAction.sequence([group, remove]))
                        
                        enemyNodes.removeValue(forKey: enemy.id)
                    }
                }
            }
            
            // Remove nodes for enemies that no longer exist
            let currentEnemyIds = Set(viewModel.enemies.map { $0.id })
            for (id, node) in enemyNodes {
                if !currentEnemyIds.contains(id) {
                    node.removeFromParentNode()
                    enemyNodes.removeValue(forKey: id)
                }
            }
        }
        
        /// Create enemy node with animal sprite
        private func createEnemyNode(for animalType: AnimalType) -> SCNNode {
            // Create a plane to display the sprite
            let plane = SCNPlane(width: CGFloat(animalType.size * 2), height: CGFloat(animalType.size * 2))
            
            // Try to load the animal image, fallback to colored disc if not available
            if let image = NSImage(named: animalType.imageName) {
                plane.firstMaterial?.diffuse.contents = image
                plane.firstMaterial?.isDoubleSided = true
                plane.firstMaterial?.lightingModel = .constant  // No lighting, just show the image
            } else {
                // Fallback to colored disc for animals without images
                plane.firstMaterial?.diffuse.contents = NSColor.systemRed
                plane.firstMaterial?.emission.contents = NSColor.systemRed.withAlphaComponent(0.3)
            }
            
            let node = SCNNode(geometry: plane)
            
            // Add subtle floating animation
            let floatUp = SCNAction.moveBy(x: 0, y: 0.1, z: 0, duration: 1.0)
            floatUp.timingMode = .easeInEaseOut
            let floatDown = floatUp.reversed()
            let floatSequence = SCNAction.sequence([floatUp, floatDown])
            let repeatFloat = SCNAction.repeatForever(floatSequence)
            node.runAction(repeatFloat)
            
            return node
        }
        
        /// Update laser aiming line
        private func updateLaser() {
            guard let scene = scene,
                  let laserNode = scene.rootNode.childNode(withName: "laser", recursively: false) else {
                return
            }
            
            if viewModel.isHandDetected() {
                laserNode.isHidden = false
                
                let direction = viewModel.getAimDirection()
                let length: Float = 20.0
                let endPoint = direction * length
                
                // Position laser
                let midPoint = endPoint * 0.5
                laserNode.position = SCNVector3(midPoint.x, midPoint.y, midPoint.z)
                
                // Orient laser
                let up = SIMD3<Float>(0, 1, 0)
                let axis = normalize(cross(up, direction))
                let angle = acos(dot(up, direction))
                laserNode.rotation = SCNVector4(axis.x, axis.y, axis.z, angle)
            } else {
                laserNode.isHidden = true
            }
        }
        
        /// Update floating text nodes
        private func updateFloatingTexts() {
            guard let scene = scene else { return }
            
            for text in viewModel.floatingTexts {
                if let node = textNodes[text.id] {
                    text.node = node
                } else {
                    let node = createTextNode(text: text.text, color: text.text == "HIT" ? .green : .red)
                    node.position = SCNVector3(text.position.x, text.position.y, text.position.z)
                    scene.rootNode.addChildNode(node)
                    textNodes[text.id] = node
                    text.node = node
                }
            }
            
            // Remove expired texts
            let currentTextIds = Set(viewModel.floatingTexts.map { $0.id })
            for (id, node) in textNodes {
                if !currentTextIds.contains(id) {
                    node.removeFromParentNode()
                    textNodes.removeValue(forKey: id)
                }
            }
        }
        
        /// Create floating text node
        private func createTextNode(text: String, color: NSColor) -> SCNNode {
            let textGeometry = SCNText(string: text, extrusionDepth: 0.1)
            textGeometry.font = NSFont.boldSystemFont(ofSize: 1)
            textGeometry.firstMaterial?.diffuse.contents = color
            textGeometry.firstMaterial?.emission.contents = color.withAlphaComponent(0.5)
            
            let node = SCNNode(geometry: textGeometry)
            node.scale = SCNVector3(0.1, 0.1, 0.1)
            
            // Billboard constraint (always face camera)
            let billboardConstraint = SCNBillboardConstraint()
            billboardConstraint.freeAxes = [.X, .Y]
            node.constraints = [billboardConstraint]
            
            return node
        }
    }
}
