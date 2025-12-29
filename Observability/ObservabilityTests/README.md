# 📸 Snapshot Testing Guide

## Overview

This directory contains snapshot tests for visual regression testing across all platforms and color schemes.

## Running Snapshot Tests

### Run All Snapshot Tests
```bash
make test-snapshots
```

### Run Specific Test
```bash
xcodebuild test -project Observability.xcodeproj \
  -scheme Observability \
  -destination "platform=iOS Simulator,name=iPhone 15 Pro" \
  -only-testing:ObservabilityTests/SnapshotTests/testDashboardView_iOS_Light_iPhone15Pro
```

## Generating the Dashboard

After running snapshot tests, generate the HTML dashboard:

```bash
make snapshot-dashboard
```

This will create `snapshot-dashboard/index.html` with all snapshots organized by platform, color scheme, and device.

## Test Variants

Each view is tested across:
- **Platforms**: iOS, macOS
- **Color Schemes**: Light, Dark
- **Devices**: iPhone 15 Pro, iPhone SE, iPad Pro, MacBook Pro

## Adding New Snapshot Tests

1. Create a test function in `SnapshotTests.swift`:
```swift
func testMyView_iOS_Light_iPhone15Pro() {
    assertSnapshot(
        matching: MyView(),
        config: .init(platform: .iOS, colorScheme: .light, device: .iPhone15Pro)
    )
}
```

2. Add preview variants in `PreviewVariants.swift` for Xcode Previews

3. Run tests and generate dashboard:
```bash
make test-snapshots
make snapshot-dashboard
```

## Snapshot Files

Snapshots are stored in `__Snapshots__/` directory (created automatically by SwiftSnapshotTesting).

## Updating Snapshots

If UI changes are intentional, update snapshots:
```bash
# Set environment variable to record new snapshots
RECORD_SNAPSHOTS=1 make test-snapshots
```
