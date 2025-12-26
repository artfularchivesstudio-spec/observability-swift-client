//
//  HapticsManager.swift
//  Observability
//
//  📳 The Cosmic Haptic Conductor - Where Touch Becomes Feeling ✨
//
//  "The tactile feedback orchestra, translating digital events
//   into physical sensations that guide and delight"
//
//  - The Mystical Haptic Virtuoso
//

#if os(iOS)
import UIKit
import SwiftUI

/// 📳 Haptic feedback manager for alert and interaction feedback
@available(iOS 17, *)
@MainActor
class HapticsManager {
    static let shared = HapticsManager()
    
    private init() {}
    
    // MARK: - Alert Haptics
    
    /// 🚨 Play haptic for critical alert
    func playCriticalAlert() {
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        #endif
    }
    
    /// ⚠️ Play haptic for warning alert
    func playWarningAlert() {
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        #endif
    }
    
    /// ℹ️ Play haptic for info alert
    func playInfoAlert() {
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }
    
    /// 🎯 Play haptic for error alert
    func playErrorAlert() {
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        #endif
    }
    
    // MARK: - Interaction Haptics
    
    /// ✨ Play light impact haptic
    func playLightImpact() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        #endif
    }
    
    /// 💪 Play medium impact haptic
    func playMediumImpact() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        #endif
    }
    
    /// 🔨 Play heavy impact haptic
    func playHeavyImpact() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        #endif
    }
    
    /// 🎯 Play selection haptic
    func playSelection() {
        #if os(iOS)
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
        #endif
    }
    
    // MARK: - Service Status Haptics
    
    /// ✅ Play haptic for service becoming healthy
    func playServiceHealthy() {
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }
    
    /// 🔴 Play haptic for service going down
    func playServiceDown() {
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        #endif
    }
    
    /// ⚠️ Play haptic for service degradation
    func playServiceDegraded() {
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        #endif
    }
    
    // MARK: - Action Haptics
    
    /// ✅ Play haptic for successful action
    func playSuccess() {
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }
    
    /// ❌ Play haptic for failed action
    func playFailure() {
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        #endif
    }
}

/// 🎨 SwiftUI view modifier for haptic feedback
@available(iOS 17, *)
struct HapticFeedback: ViewModifier {
    let style: HapticStyle
    let onTap: () -> Void
    
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                HapticsManager.shared.playHaptic(for: style)
                onTap()
            }
    }
}

@available(macOS 14, iOS 17, *)
enum HapticStyle {
    case lightImpact
    case mediumImpact
    case heavyImpact
    case selection
    case success
    case error
    case warning
    case criticalAlert
    case serviceHealthy
    case serviceDown
    case serviceDegraded
}

@available(macOS 14, iOS 17, *)
extension HapticsManager {
    func playHaptic(for style: HapticStyle) {
        switch style {
        case .lightImpact:
            playLightImpact()
        case .mediumImpact:
            playMediumImpact()
        case .heavyImpact:
            playHeavyImpact()
        case .selection:
            playSelection()
        case .success:
            playSuccess()
        case .error:
            playErrorAlert()
        case .warning:
            playWarningAlert()
        case .criticalAlert:
            playCriticalAlert()
        case .serviceHealthy:
            playServiceHealthy()
        case .serviceDown:
            playServiceDown()
        case .serviceDegraded:
            playServiceDegraded()
        }
    }
}

@available(iOS 17, *)
extension View {
    func hapticFeedback(_ style: HapticStyle, action: @escaping () -> Void) -> some View {
        modifier(HapticFeedback(style: style, onTap: action))
    }
}
#endif
