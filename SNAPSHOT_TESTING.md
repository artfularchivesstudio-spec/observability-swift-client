# 📸 Snapshot Testing Guide

## Overview

This project includes comprehensive snapshot testing for visual regression testing across all platforms, color schemes, and device sizes.

## What is Snapshot Testing?

Snapshot testing captures screenshots of your UI components and compares them against previously saved "golden" images. This helps catch visual regressions automatically.

## Test Coverage

### Variants Tested

Each component/view is tested across:

- **Platforms**: iOS, macOS
- **Color Schemes**: Light Mode, Dark Mode  
- **Devices**: 
  - iPhone 15 Pro (393×852)
  - iPhone SE (375×667)
  - iPad Pro 12.9" (1024×1366)
  - MacBook Pro (1440×900)

**Total: 8 variants per component**

### Components Tested

1. **DashboardView** - Main dashboard interface
2. **ServiceDetailView** - Individual service detail view
3. **ServiceStatusIndicator** - Status indicator component
4. **MetricChart** - Metrics visualization component

## Running Snapshot Tests

### Run All Snapshot Tests

```bash
make test-snapshots
```

Or directly:

```bash
xcodebuild test -project Observability.xcodeproj \
  -scheme Observability \
  -destination "platform=iOS Simulator,name=iPhone 15 Pro" \
  -only-testing:ObservabilityTests/SnapshotTests
```

### Run Specific Test

```bash
xcodebuild test -project Observability.xcodeproj \
  -scheme Observability \
  -destination "platform=iOS Simulator,name=iPhone 15 Pro" \
  -only-testing:ObservabilityTests/SnapshotTests/testDashboardView_iOS_Light_iPhone15Pro
```

### Run Component Tests

```bash
xcodebuild test -project Observability.xcodeproj \
  -scheme Observability \
  -destination "platform=iOS Simulator,name=iPhone 15 Pro" \
  -only-testing:ObservabilityTests/ComponentSnapshotTests
```

## Generating the Dashboard

After running snapshot tests, generate the HTML dashboard:

```bash
make snapshot-dashboard
```

This will:
1. Find all snapshot images in `__Snapshots__/`
2. Generate `snapshot-dashboard/index.html`
3. Create an interactive gallery with filters

Open `snapshot-dashboard/index.html` in your browser to view all snapshots.

## Updating Snapshots

When UI changes are intentional, update snapshots:

```bash
# Set environment variable to record new snapshots
RECORD_SNAPSHOTS=1 make test-snapshots
```

Or in Xcode:
1. Set `RECORD_SNAPSHOTS=1` in scheme environment variables
2. Run snapshot tests
3. Snapshots will be updated

## Adding New Snapshot Tests

### 1. Create Test Function

Add to `SnapshotTests.swift` or `ComponentSnapshotTests.swift`:

```swift
func testMyView_iOS_Light_iPhone15Pro() {
    assertSnapshot(
        matching: MyView(),
        config: .init(platform: .iOS, colorScheme: .light, device: .iPhone15Pro)
    )
}
```

### 2. Add Preview Variants

Add to `PreviewVariants.swift` for Xcode Previews:

```swift
struct MyView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PreviewVariants(config: .init(platform: .iOS, colorScheme: .light, device: .iPhone15Pro)) {
                MyView()
            }
            .previewDisplayName("iOS Light - iPhone 15 Pro")
            
            // Add more variants...
        }
    }
}
```

### 3. Test All Variants

Use `assertSnapshotAllVariants` to test all combinations:

```swift
func testMyView_AllVariants() {
    assertSnapshotAllVariants(matching: MyView())
}
```

## Snapshot Files

- **Location**: `__Snapshots__/` directory (auto-created)
- **Format**: PNG images
- **Naming**: `TestName_ConfigName.png`
- **Example**: `testDashboardView_iOS_Light_iPhone15Pro.png`

## Dashboard Features

The HTML dashboard includes:

- **Statistics**: Total snapshots, platform breakdown, color scheme counts
- **Filters**: Filter by platform, color scheme, device
- **Gallery**: Grid view of all snapshots
- **Modal View**: Click any snapshot to view full-size
- **Responsive**: Works on desktop and mobile

## CI/CD Integration

Add to your CI pipeline:

```yaml
# Example GitHub Actions
- name: Run Snapshot Tests
  run: |
    xcodebuild test \
      -project Observability.xcodeproj \
      -scheme Observability \
      -destination "platform=iOS Simulator,name=iPhone 15 Pro" \
      -only-testing:ObservabilityTests/SnapshotTests

- name: Generate Dashboard
  run: make snapshot-dashboard
  
- name: Upload Dashboard
  uses: actions/upload-artifact@v3
  with:
    name: snapshot-dashboard
    path: snapshot-dashboard/
```

## Troubleshooting

### Snapshots Don't Match

1. **Check if changes are intentional**: If yes, update snapshots
2. **Check device/simulator**: Ensure using correct simulator
3. **Check color scheme**: Verify light/dark mode settings
4. **Check timing**: Some animations may cause flakiness

### Tests Fail to Run

1. **Check dependencies**: Ensure SwiftSnapshotTesting is installed
2. **Check imports**: Verify all imports are correct
3. **Check test target**: Ensure test target has correct dependencies

### Dashboard Not Generating

1. **Check snapshots exist**: Run tests first
2. **Check script permissions**: `chmod +x scripts/generate-snapshot-dashboard.sh`
3. **Check paths**: Verify snapshot directory exists

## Best Practices

1. **Test critical paths**: Focus on user-facing components
2. **Keep snapshots updated**: Update when UI changes intentionally
3. **Review failures**: Don't blindly update snapshots
4. **Use descriptive names**: Make test names clear
5. **Test edge cases**: Empty states, loading states, error states

## Resources

- [SwiftSnapshotTesting Documentation](https://github.com/pointfreeco/swift-snapshot-testing)
- [Visual Regression Testing Guide](https://www.swiftbysundell.com/articles/snapshot-testing-in-swift/)
