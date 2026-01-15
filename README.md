# LaserPalm

A native macOS gesture shooting game built with SwiftUI, AVFoundation, Vision, and SceneKit.

## Overview

LaserPalm is an AR-style shooting game that uses your Mac's camera to detect hand gestures. Make a pistol gesture with your hand, aim with your index finger, and shoot flying disc targets!

## Features

### Gesture Recognition
- **Pistol Gesture Detection**: Index finger extended, other fingers curled
- **Aiming**: Point your index finger to aim
- **Shooting**: Move your thumb toward your index finger to trigger
- **State-based Shooting**: No continuous fire - each shot requires a trigger motion

### Gameplay
- **Flying Disc Enemies**: 3D targets that spawn from screen edges
- **Always 4 Active Enemies**: Instant replacement when destroyed
- **Smooth Movement**: Frame-rate independent physics
- **Magnetic Aim Assist**: Crosshair gently snaps toward nearby targets

### Visual Effects
- **Laser Aiming Line**: Cyan laser from your fingertip into 3D space
- **Hit Feedback**: Visual flash and sound on successful hit
- **Floating Text VFX**: "HIT" and "MISS" text that floats and fades
- **Real-time HUD**: Score, accuracy, and hand detection status

### Stability Features
- **Safe Startup**: Loading screen until camera and Vision are ready
- **Crash-Safe Vision**: All Vision processing wrapped in error handling
- **Throttled Processing**: Vision runs at ~8 FPS to preserve performance
- **60 FPS Rendering**: Smooth SceneKit rendering at 60 FPS
- **Background Processing**: Vision runs on background queue

## Architecture

### MVVM Pattern
```
LaserPalm/
├── Models/
│   ├── GameState.swift      # Game state and hand gesture models
│   ├── Enemy.swift           # Enemy disc with physics & collision
│   └── FloatingText.swift    # Floating text VFX
├── Managers/
│   ├── CameraManager.swift   # AVFoundation camera capture
│   ├── VisionManager.swift   # Hand pose detection
│   └── AudioManager.swift    # Sound effects
├── ViewModels/
│   └── GameViewModel.swift   # Game logic coordinator
└── Views/
    ├── LoadingView.swift     # Startup loading screen
    ├── GameView.swift        # Main game view with HUD
    └── GameSceneView.swift   # SceneKit 3D rendering
```

### Technology Stack
- **UI**: SwiftUI
- **Camera**: AVFoundation (AVCaptureSession)
- **Vision**: Vision framework (VNDetectHumanHandPoseRequest)
- **3D Rendering**: SceneKit
- **Audio**: AVFoundation + System Sounds

## Apple Platform Integration

LaserPalm is built as a **standard Apple macOS application** following Apple's best practices:

### Security & Privacy
- **App Sandbox** - Fully sandboxed for user security
- **Hardened Runtime** - Enhanced security with hardened runtime
- **Privacy Descriptions** - Clear camera usage explanation
- **Local Processing** - All gesture detection happens on-device
- **No Network Access** - Completely offline, no data collection

### macOS Integration
- **Native SwiftUI** - Built with SwiftUI for modern macOS
- **Dark Mode** - Automatic dark mode support
- **Settings Window** - Standard macOS Settings (⌘,)
- **Menu Bar Integration** - Custom menu items and keyboard shortcuts
- **Window Management** - Proper window sizing and behavior
- **Retina Display** - Full high-resolution support

### Performance
- **Metal Graphics** - Hardware-accelerated rendering
- **60 FPS Rendering** - Smooth SceneKit at 60 FPS
- **Efficient Vision** - Throttled at ~8 FPS for optimal performance
- **Background Processing** - Vision runs on background threads
- **Memory Efficient** - Automatic resource cleanup

### Accessibility
- **Keyboard Shortcuts** - Full keyboard navigation support
- **VoiceOver Ready** - Accessible UI elements
- **System Appearance** - Respects system preferences

## Requirements

- **macOS 15.6 (Sequoia) or later**
- Mac with built-in camera (MacBook Air/Pro, iMac, Mac Studio Display)
- Apple Silicon (M1/M2/M3/M4) or Intel processor
- Minimum 8GB RAM recommended
- Camera permission required

## Setup & Build

### 1. Open in Xcode
```bash
cd /Users/phincon/Documents/Project/LaserPalm
open LaserPalm.xcodeproj
```

### 2. Add Files to Xcode Project
You need to add the newly created files to your Xcode project:

1. In Xcode, right-click on the `LaserPalm` folder in the Project Navigator
2. Select "Add Files to LaserPalm..."
3. Add these folders:
   - `Models/` (all 3 files)
   - `Managers/` (all 3 files)
   - `ViewModels/` (GameViewModel.swift)
   - `Views/` (all 3 files)
   - `Info.plist`

### 3. Configure Info.plist in Xcode
1. Select the LaserPalm project in Project Navigator
2. Select the LaserPalm target
3. Go to "Info" tab
4. Click "Choose Info.plist File..."
5. Select the `Info.plist` file we created

### 4. Build & Run
1. Select your Mac as the target device
2. Press `Cmd + R` to build and run
3. Grant camera permission when prompted

## How to Play

### Making the Pistol Gesture
1. **Extend your index finger** - This is your aiming direction
2. **Curl your middle, ring, and pinky fingers** - Keep them folded
3. **Keep your thumb up** - This is your trigger

### Shooting
1. **Aim** by pointing your index finger at a target
2. **Shoot** by moving your thumb toward your index finger
3. The laser line shows your aim direction
4. The crosshair provides magnetic aim assist

### Scoring
- **+100 points** per hit
- Track your **accuracy** in the HUD
- Try to maintain high accuracy!

## Performance Optimization

### Vision Processing
- Throttled to ~8 FPS (every 120ms)
- Runs on background queue
- Never blocks main thread

### Rendering
- SceneKit at 60 FPS
- Efficient enemy spawning/despawning
- Optimized collision detection

### Memory Management
- Weak references to prevent retain cycles
- Automatic node cleanup
- Efficient texture usage

## Troubleshooting

### Camera Not Working
- Check System Preferences > Privacy & Security > Camera
- Ensure LaserPalm has camera permission
- Restart the app after granting permission

### Hand Not Detected
- Ensure good lighting
- Position your hand clearly in front of the camera
- Make sure fingers are clearly separated
- Try moving closer to the camera

### Performance Issues
- Close other camera-using applications
- Ensure your Mac meets minimum requirements
- Check Activity Monitor for CPU/GPU usage

## Code Highlights

### Crash-Safe Vision Processing
```swift
do {
    let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
    try handler.perform([request])
    // Process results...
} catch {
    print("Vision processing error: \(error.localizedDescription)")
    // Fail gracefully - never crash
}
```

### State-Based Trigger Detection
```swift
var didTrigger: Bool {
    return isTriggerPulled && !lastTriggerState
}
```

### Magnetic Aim Assist
```swift
if let enemy = closestEnemy {
    let toEnemy = normalize(enemy.position - rayOrigin)
    return normalize(direction * 0.7 + toEnemy * 0.3)
}
```

## Future Enhancements

- [ ] Multiple difficulty levels
- [ ] Power-ups and special weapons
- [ ] Leaderboard integration
- [ ] Custom sound effects
- [ ] Particle effects for explosions
- [ ] Two-handed gestures for special moves

## License

Created for educational purposes.

## Credits

Built with ❤️ using SwiftUI, Vision, and SceneKit.

---
