//
//  ScreenShake.swift
//  LaserPalm
//
//  Created by Elmee on 21/12/2025.
//

import SwiftUI
import Combine

/// Screen shake effect for impact feedback
struct ScreenShakeModifier: ViewModifier {
    @Binding var shakeAmount: CGFloat
    
    func body(content: Content) -> some View {
        content
            .offset(x: shakeAmount, y: 0)
            .animation(.linear(duration: 0.05), value: shakeAmount)
    }
}

extension View {
    func screenShake(_ amount: Binding<CGFloat>) -> some View {
        modifier(ScreenShakeModifier(shakeAmount: amount))
    }
}

/// Screen shake manager
class ScreenShakeManager: ObservableObject {
    @Published var shakeOffset: CGFloat = 0
    
    /// Trigger screen shake
    func shake(intensity: CGFloat = 10) {
        let sequence: [CGFloat] = [intensity, -intensity, intensity * 0.7, -intensity * 0.7, intensity * 0.4, -intensity * 0.4, 0]
        
        for (index, offset) in sequence.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.05) {
                self.shakeOffset = offset
            }
        }
    }
}
