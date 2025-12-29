//
//  SnapshotTestHelpers.swift
//  ObservabilityTests
//
//  📸 The Cosmic Snapshot Testing Infrastructure - Where UI Becomes Immortalized ✨
//
//  "The visual regression testing framework that captures every pixel,
//   every variant, every moment of our UI's existence"
//
//  - The Mystical Snapshot Archivist
//

import SwiftUI
import SnapshotTesting
import XCTest

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// 🎨 Snapshot test configuration for all variants
@available(macOS 14, iOS 17, *)
public struct SnapshotConfig {
    public let platform: Platform
    public let colorScheme: ColorScheme
    public let device: Device
    public let name: String
    
    public enum Platform {
        case iOS
        case macOS
    }
    
    public enum Device {
        case iPhone15Pro
        case iPhoneSE
        case iPadPro
        case macBookPro
        
        var size: CGSize {
            switch self {
            case .iPhone15Pro:
                return CGSize(width: 393, height: 852) // iPhone 15 Pro
            case .iPhoneSE:
                return CGSize(width: 375, height: 667) // iPhone SE
            case .iPadPro:
                return CGSize(width: 1024, height: 1366) // iPad Pro 12.9"
            case .macBookPro:
                return CGSize(width: 1440, height: 900) // MacBook Pro
            }
        }
    }
    
    public init(platform: Platform, colorScheme: ColorScheme, device: Device) {
        self.platform = platform
        self.colorScheme = colorScheme
        self.device = device
        self.name = "\(platform == .iOS ? "iOS" : "macOS")_\(colorScheme == .light ? "Light" : "Dark")_\(device)"
    }
    
    public static var allVariants: [SnapshotConfig] {
        [
            // iOS Light
            SnapshotConfig(platform: .iOS, colorScheme: .light, device: .iPhone15Pro),
            SnapshotConfig(platform: .iOS, colorScheme: .light, device: .iPhoneSE),
            SnapshotConfig(platform: .iOS, colorScheme: .light, device: .iPadPro),
            
            // iOS Dark
            SnapshotConfig(platform: .iOS, colorScheme: .dark, device: .iPhone15Pro),
            SnapshotConfig(platform: .iOS, colorScheme: .dark, device: .iPhoneSE),
            SnapshotConfig(platform: .iOS, colorScheme: .dark, device: .iPadPro),
            
            // macOS Light
            SnapshotConfig(platform: .macOS, colorScheme: .light, device: .macBookPro),
            
            // macOS Dark
            SnapshotConfig(platform: .macOS, colorScheme: .dark, device: .macBookPro),
        ]
    }
}

/// 🎭 Helper to create snapshot-ready views
@available(macOS 14, iOS 17, *)
public struct SnapshotWrapper<Content: View>: View {
    let content: Content
    let config: SnapshotConfig
    
    public init(config: SnapshotConfig, @ViewBuilder content: () -> Content) {
        self.config = config
        self.content = content()
    }
    
    public var body: some View {
        content
            .preferredColorScheme(config.colorScheme)
            .frame(width: config.device.size.width, height: config.device.size.height)
            #if os(iOS)
            .background(Color(.systemBackground))
            #else
            .background(Color(NSColor.windowBackgroundColor))
            #endif
    }
}

/// 📸 Snapshot testing extension for XCTest
@available(macOS 14, iOS 17, *)
extension XCTestCase {
    /// Assert snapshot for a view with all variants
    func assertSnapshot<Value: View>(
        matching value: @autoclosure () -> Value,
        config: SnapshotConfig,
        file: StaticString = #file,
        testName: String = #function,
        line: UInt = #line
    ) {
        let view = SnapshotWrapper(config: config) {
            value()
        }
        
        #if os(iOS)
        assertSnapshot(
            matching: view,
            as: .image(on: .iPhone15Pro, traits: .init(userInterfaceStyle: config.colorScheme == .light ? .light : .dark)),
            named: config.name,
            file: file,
            testName: testName,
            line: line
        )
        #else
        assertSnapshot(
            matching: view,
            as: .image,
            named: config.name,
            file: file,
            testName: testName,
            line: line
        )
        #endif
    }
    
    /// Assert snapshot for all variants
    func assertSnapshotAllVariants<Value: View>(
        matching value: @autoclosure () -> Value,
        file: StaticString = #file,
        testName: String = #function,
        line: UInt = #line
    ) {
        for config in SnapshotConfig.allVariants {
            assertSnapshot(
                matching: value(),
                config: config,
                file: file,
                testName: testName,
                line: line
            )
        }
    }
}
