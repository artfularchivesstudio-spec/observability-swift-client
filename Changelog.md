# Changelog

All notable changes to the Observability Swift Client project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- XcodeGen project configuration with comprehensive Makefile
- Multi-platform support (iOS 18.6+, macOS 15.6+, visionOS 26.1+)
- Sandbox and hardened runtime security configurations
- Comprehensive .gitignore for Xcode projects
- Project documentation structure

### Changed
- Initial project setup with file system synchronization

## [0.1.0] - 2025-12-15

### Added
- Initial project creation
- Multi-platform SwiftUI application target
- Unit testing target (ObservabilityTests)
- UI testing target (ObservabilityUITests)
- Asset catalog with app icon and accent color
- Comprehensive build configurations for Debug and Release
- Developer team and bundle identifier configuration
- Swift 5.0 with modern language features enabled
- Previews support for SwiftUI development

### Security
- App sandbox enabled with selective permissions
- Hardened runtime enabled
- Network access (incoming/outgoing) enabled
- File system access configured for downloads folder (read-only)
- User selected files access (read-write)
- Bluetooth access enabled

### Platforms
- iOS: 18.6+ with iPhone and iPad support
- macOS: 15.6+ with universal app support

### Development
- Automatic code signing
- Swift Localization with string catalogs
- Asset symbol generation
- Strict compiler warnings
- Debug and release configurations optimized for respective environments