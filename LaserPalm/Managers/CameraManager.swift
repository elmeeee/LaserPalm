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
        print("Checking camera permission...")
        
        // Check current authorization status first
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            // Already authorized, proceed immediately
            print("Camera already authorized")
            DispatchQueue.main.async {
                self.permissionGranted = true
                self.setupCamera()
            }
            
        case .notDetermined:
            // Need to request permission
            print("Requesting camera permission...")
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.permissionGranted = granted
                    if granted {
                        print("Camera permission granted")
                        self?.setupCamera()
                    } else {
                        print("Camera permission denied")
                    }
                }
            }
            
        case .denied, .restricted:
            // Permission denied or restricted
            print("Camera access denied or restricted")
            DispatchQueue.main.async {
                self.permissionGranted = false
            }
            
        @unknown default:
            print("Unknown camera authorization status")
            DispatchQueue.main.async {
                self.permissionGranted = false
            }
        }
    }
    
    
    /// Setup camera capture session
    private func setupCamera() {
        print("🎥 Setting up camera...")
        
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            do {
                // Configure session
                print("📹 Configuring capture session...")
                self.captureSession.beginConfiguration()
                
                // Remove all existing inputs and outputs (in case of restart)
                print("🧹 Cleaning up existing inputs/outputs...")
                for input in self.captureSession.inputs {
                    self.captureSession.removeInput(input)
                }
                for output in self.captureSession.outputs {
                    self.captureSession.removeOutput(output)
                }
                
                self.captureSession.sessionPreset = .vga640x480
                
                // Get camera device
                print("Looking for front camera...")
                guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
                    print("No front camera available")
                    DispatchQueue.main.async {
                        self.errorMessage = "No front camera found"
                        self.isReady = false
                    }
                    return
                }
                
                print("Found camera: \(camera.localizedName)")
                
                // Add camera input
                print("Adding camera input...")
                let input = try AVCaptureDeviceInput(device: camera)
                if self.captureSession.canAddInput(input) {
                    self.captureSession.addInput(input)
                    print("Camera input added")
                } else {
                    print("Cannot add camera input")
                    throw NSError(domain: "CameraManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Cannot add camera input"])
                }
                
                // Configure video output
                print("📹 Configuring video output...")
                self.videoOutput.setSampleBufferDelegate(self, queue: self.sessionQueue)
                self.videoOutput.alwaysDiscardsLateVideoFrames = true
                self.videoOutput.videoSettings = [
                    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
                ]
                
                if self.captureSession.canAddOutput(self.videoOutput) {
                    self.captureSession.addOutput(self.videoOutput)
                    print("Video output added")
                } else {
                    print("Cannot add video output")
                    throw NSError(domain: "CameraManager", code: -2, userInfo: [NSLocalizedDescriptionKey: "Cannot add video output"])
                }
                
                self.captureSession.commitConfiguration()
                print("Configuration committed")
                
                // Start session
                print("Starting capture session...")
                self.captureSession.startRunning()
                print("Capture session running")
                
                DispatchQueue.main.async {
                    self.isReady = true
                    print("Camera fully ready!")
                }
                
            } catch {
                print("Camera setup failed: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.errorMessage = "Camera setup failed: \(error.localizedDescription)"
                    self.isReady = false
                }
            }
        }
    }
    
    /// Stop camera session
    func stop() {
        print("🛑 Stopping camera session...")
        sessionQueue.async { [weak self] in
            self?.captureSession.stopRunning()
        }
        // Reset ready state so it can be reinitialized
        DispatchQueue.main.async { [weak self] in
            self?.isReady = false
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
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
