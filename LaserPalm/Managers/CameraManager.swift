//
//  CameraManager.swift
//  LaserPalm
//
//  Created by Elmee on 19/12/2025.
//

import AVFoundation
import Combine

/// Manages camera capture session for hand tracking
class CameraManager: NSObject, ObservableObject {
    @Published var isReady = false
    @Published var permissionGranted = false
    @Published var currentFrame: CVPixelBuffer?
    @Published var errorMessage: String?
    
    private let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let sessionQueue = DispatchQueue(label: "com.laserpalm.camera")
    
    override init() {
        super.init()
    }
    
    /// Request camera permission
    func requestPermission() {
        
        // Check current authorization status first
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            // Already authorized, proceed immediately
            DispatchQueue.main.async {
                self.permissionGranted = true
                self.setupCamera()
            }
            
        case .notDetermined:
            // Need to request permission
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.permissionGranted = granted
                    if granted {
                        self?.setupCamera()
                    } else {
                    }
                }
            }
            
        case .denied, .restricted:
            // Permission denied or restricted
            DispatchQueue.main.async {
                self.permissionGranted = false
            }
            
        @unknown default:
            DispatchQueue.main.async {
                self.permissionGranted = false
            }
        }
    }
    
    
    /// Setup camera capture session
    private func setupCamera() {
        
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            do {
                // Configure session
                self.captureSession.beginConfiguration()
                
                // Remove all existing inputs and outputs (in case of restart)
                for input in self.captureSession.inputs {
                    self.captureSession.removeInput(input)
                }
                for output in self.captureSession.outputs {
                    self.captureSession.removeOutput(output)
                }
                
                self.captureSession.sessionPreset = .vga640x480
                
                // Get camera device
                guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
                    DispatchQueue.main.async {
                        self.errorMessage = "No front camera found"
                        self.isReady = false
                    }
                    return
                }
                
                
                // Add camera input
                let input = try AVCaptureDeviceInput(device: camera)
                if self.captureSession.canAddInput(input) {
                    self.captureSession.addInput(input)
                } else {
                    throw NSError(domain: "CameraManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Cannot add camera input"])
                }
                
                // Configure video output
                self.videoOutput.setSampleBufferDelegate(self, queue: self.sessionQueue)
                self.videoOutput.alwaysDiscardsLateVideoFrames = true
                self.videoOutput.videoSettings = [
                    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
                ]
                
                if self.captureSession.canAddOutput(self.videoOutput) {
                    self.captureSession.addOutput(self.videoOutput)
                } else {
                    throw NSError(domain: "CameraManager", code: -2, userInfo: [NSLocalizedDescriptionKey: "Cannot add video output"])
                }
                
                self.captureSession.commitConfiguration()
                
                // Start session
                self.captureSession.startRunning()
                
                DispatchQueue.main.async {
                    self.isReady = true
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Camera setup failed: \(error.localizedDescription)"
                    self.isReady = false
                }
            }
        }
    }
    
    /// Stop camera session
    func stop() {
        sessionQueue.async { [weak self] in
            self?.captureSession.stopRunning()
        }
        // Reset ready state so it can be reinitialized
        DispatchQueue.main.async { [weak self] in
            self?.isReady = false
        }
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        // CVPixelBuffer is thread-safe for reading, safe to capture
        nonisolated(unsafe) let buffer = pixelBuffer
        DispatchQueue.main.async { [weak self] in
            self?.currentFrame = buffer
        }
    }
}
