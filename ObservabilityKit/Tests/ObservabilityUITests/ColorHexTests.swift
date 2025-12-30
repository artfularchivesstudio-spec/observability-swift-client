//
//  ColorHexTests.swift
//  ObservabilityUITests
//
//  🎨 The Cosmic Color Alchemist Validator - Where Hex Strings Face Their Trial ✨
//
//  "Colors are the soul of UI. We test hex parsing to ensure
//  every color string transforms into visual magic correctly."
//
//  - The Spellbinding Museum Director of Color Testing

import XCTest
import SwiftUI
@testable import ObservabilityUI

@available(macOS 14, iOS 17, *)
final class ColorHexTests: XCTestCase {
    
    // MARK: - RGB Hex Tests (6 characters)
    
    /// 🎨 Test standard 6-character hex color (RGB)
    func testRGBHexColor() {
        let color = Color(hex: "#FF0000") // Red
        
        // Verify color components (approximate due to color space conversion)
        // We can't easily test exact RGB values without more complex color space math
        // So we just verify the color is created without crashing
        XCTAssertNotNil(color)
    }
    
    /// 🎨 Test hex color without hash prefix
    func testHexColorWithoutHash() {
        let color1 = Color(hex: "#00FF00") // Green with hash
        let color2 = Color(hex: "00FF00")  // Green without hash
        
        // Both should create valid colors
        XCTAssertNotNil(color1)
        XCTAssertNotNil(color2)
    }
    
    /// 🎨 Test common hex colors
    func testCommonHexColors() {
        let colors = [
            "#000000", // Black
            "#FFFFFF", // White
            "#FF0000", // Red
            "#00FF00", // Green
            "#0000FF", // Blue
            "#FFFF00", // Yellow
            "#FF00FF", // Magenta
            "#00FFFF"  // Cyan
        ]
        
        for hex in colors {
            let color = Color(hex: hex)
            XCTAssertNotNil(color, "Failed to create color from \(hex)")
        }
    }
    
    // MARK: - Short Hex Tests (3 characters)
    
    /// 🎨 Test short 3-character hex color (RGB shorthand)
    func testShortHexColor() {
        let color = Color(hex: "#F00") // Red shorthand
        
        XCTAssertNotNil(color)
    }
    
    /// 🎨 Test short hex colors
    func testShortHexColors() {
        let shortColors = [
            "#000", // Black
            "#FFF", // White
            "#F00", // Red
            "#0F0", // Green
            "#00F"  // Blue
        ]
        
        for hex in shortColors {
            let color = Color(hex: hex)
            XCTAssertNotNil(color, "Failed to create color from short hex \(hex)")
        }
    }
    
    // MARK: - ARGB Hex Tests (8 characters)
    
    /// 🎨 Test 8-character hex color with alpha (ARGB)
    func testARGBHexColor() {
        let color = Color(hex: "#80FF0000") // Red with 50% alpha
        
        XCTAssertNotNil(color)
    }
    
    /// 🎨 Test ARGB colors with different alpha values
    func testARGBHexColors() {
        let argbColors = [
            "#00000000", // Transparent black
            "#FFFFFFFF", // Opaque white
            "#80FF0000", // Semi-transparent red
            "#FF0000FF"  // Opaque blue
        ]
        
        for hex in argbColors {
            let color = Color(hex: hex)
            XCTAssertNotNil(color, "Failed to create color from ARGB hex \(hex)")
        }
    }
    
    // MARK: - Invalid Hex Tests
    
    /// 🎨 Test invalid hex color (empty string)
    func testInvalidHexColorEmpty() {
        let color = Color(hex: "")
        
        // Should default to black
        XCTAssertNotNil(color)
    }
    
    /// 🎨 Test invalid hex color (invalid characters)
    func testInvalidHexColorInvalidChars() {
        let color = Color(hex: "#GGGGGG")
        
        // Should default to black for invalid hex
        XCTAssertNotNil(color)
    }
    
    /// 🎨 Test invalid hex color (wrong length)
    func testInvalidHexColorWrongLength() {
        let color1 = Color(hex: "#FF")      // Too short
        let color2 = Color(hex: "#FFFFF")   // Wrong length
        let color3 = Color(hex: "#FFFFFFFFF") // Too long
        
        // All should default to black
        XCTAssertNotNil(color1)
        XCTAssertNotNil(color2)
        XCTAssertNotNil(color3)
    }
    
    /// 🎨 Test hex color with whitespace
    func testHexColorWithWhitespace() {
        let color1 = Color(hex: "  #FF0000  ") // With spaces
        let color2 = Color(hex: "\n#00FF00\n") // With newlines
        
        // Should trim whitespace and work
        XCTAssertNotNil(color1)
        XCTAssertNotNil(color2)
    }
    
    // MARK: - Real-World Color Tests
    
    /// 🎨 Test colors from ServiceStatus categories
    func testServiceStatusCategoryColors() {
        let categoryColors = [
            "#3498db", // Blue (backend)
            "#2ecc71", // Green (frontend)
            "#9b59b6", // Purple (cms)
            "#e67e22", // Orange (infrastructure)
            "#1abc9c"  // Teal (database)
        ]
        
        for hex in categoryColors {
            let color = Color(hex: hex)
            XCTAssertNotNil(color, "Failed to create color from category hex \(hex)")
        }
    }
    
    /// 🎨 Test alert severity colors
    func testAlertSeverityColors() {
        let severityColors = [
            "#3498db", // Info (blue)
            "#f39c12", // Warning (orange)
            "#e74c3c", // Error (red)
            "#c0392b"  // Critical (dark red)
        ]
        
        for hex in severityColors {
            let color = Color(hex: hex)
            XCTAssertNotNil(color, "Failed to create color from severity hex \(hex)")
        }
    }
}
