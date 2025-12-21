//
//  VisionManager.swift
//  LaserPalm
//
//  Created by Elmee on 19/12/2025.
//

import Vision
import CoreImage
import Combine

/// Manages hand pose detection using Vision framework
class VisionManager: ObservableObject {
    @Published var handGesture = HandGesture()
    
    private var lastProcessTime: Date = Date()
    private let processingInterval: TimeInterval = 0.05 // ~20 FPS for smoother tracking
    
    // Smoothing for position
    private var smoothedPosition: SIMD2<Float> = .zero
    private let smoothingFactor: Float = 0.3 // Lower = smoother but more lag
    
    /// Process frame for hand detection (throttled)
    func processFrame(_ pixelBuffer: CVPixelBuffer) {
        // Throttle processing
        let now = Date()
        guard now.timeIntervalSince(lastProcessTime) >= processingInterval else { return }
        lastProcessTime = now
        
        // Process on background queue
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.detectHandPose(in: pixelBuffer)
        }
    }
    
    /// Detect hand pose using Vision
    private func detectHandPose(in pixelBuffer: CVPixelBuffer) {
        let request = VNDetectHumanHandPoseRequest()
        request.maximumHandCount = 1
        
        do {
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            try handler.perform([request])
            
            guard let observation = request.results?.first else {
                DispatchQueue.main.async { [weak self] in
                    self?.handGesture.isDetected = false
                }
                return
            }
            
            // Extract hand landmarks
            try processHandLandmarks(observation)
            
        } catch {
            // Fail gracefully - don't crash
            DispatchQueue.main.async { [weak self] in
                self?.handGesture.isDetected = false
            }
        }
    }
    
    /// Process hand landmarks to detect pistol gesture
    private func processHandLandmarks(_ observation: VNHumanHandPoseObservation) throws {
        // Get key points
        guard let indexTip = try? observation.recognizedPoint(.indexTip),
              let indexDIP = try? observation.recognizedPoint(.indexDIP),
              let thumbTip = try? observation.recognizedPoint(.thumbTip),
              let middleTip = try? observation.recognizedPoint(.middleTip),
              let ringTip = try? observation.recognizedPoint(.ringTip),
              let littleTip = try? observation.recognizedPoint(.littleTip),
              let wrist = try? observation.recognizedPoint(.wrist) else {
            return
        }
        
        // Check confidence
        guard indexTip.confidence > 0.3 && thumbTip.confidence > 0.3 else {
            DispatchQueue.main.async { [weak self] in
                self?.handGesture.isDetected = false
            }
            return
        }
        
        // Detect pistol gesture:
        // - Index finger extended
        // - Middle, ring, pinky curled
        // - Thumb up
        
        let indexExtended = distance(indexTip.location, wrist.location) > distance(indexDIP.location, wrist.location)
        let middleCurled = distance(middleTip.location, wrist.location) < distance(indexTip.location, wrist.location) * 0.8
        let ringCurled = distance(ringTip.location, wrist.location) < distance(indexTip.location, wrist.location) * 0.8
        let littleCurled = distance(littleTip.location, wrist.location) < distance(indexTip.location, wrist.location) * 0.8
        
        let isPistolGesture = indexExtended && middleCurled && ringCurled && littleCurled
        
        // Calculate aim direction (from wrist to index tip)
        let aimX = Float(indexTip.location.x - wrist.location.x)
        let aimY = Float(indexTip.location.y - wrist.location.y)
        let aimDirection = normalize(SIMD3<Float>(aimX, aimY, -1.0))
        
        // Detect trigger (thumb movement toward index)
        let thumbIndexDistance = distance(thumbTip.location, indexTip.location)
        let isTriggerPulled = thumbIndexDistance < 0.08 // Threshold for trigger
        
        // Apply smoothing to position
        let rawPosition = SIMD2<Float>(Float(indexTip.location.x), Float(indexTip.location.y))
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Smooth position using exponential moving average
            self.smoothedPosition = self.smoothedPosition * (1.0 - self.smoothingFactor) + rawPosition * self.smoothingFactor
            
            self.handGesture.isDetected = isPistolGesture
            self.handGesture.fingerTipPosition = self.smoothedPosition
            self.handGesture.aimDirection = aimDirection
            self.handGesture.isTriggerPulled = isTriggerPulled && isPistolGesture
        }
    }
    
    /// Calculate distance between two points
    private func distance(_ p1: CGPoint, _ p2: CGPoint) -> CGFloat {
        let dx = p1.x - p2.x
        let dy = p1.y - p2.y
        return sqrt(dx * dx + dy * dy)
    }
}
