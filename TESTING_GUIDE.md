# 🧪 Testing Guide

## Overview

The Observability Swift Client includes comprehensive testing coverage:
- **Unit Tests**: Business logic and model validation
- **Integration Tests**: API and network layer testing
- **UI Tests**: User interaction and flow testing
- **Snapshot Tests**: Visual regression testing

## Running Tests

### In Xcode

1. **Run All Tests**: `Cmd + U`
2. **Run Specific Test**: Click diamond icon next to test
3. **Run Test Suite**: Right-click test suite → Run

### Command Line

```bash
# Run all tests
xcodebuild test \
  -scheme Observability \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Run specific test suite
xcodebuild test \
  -scheme Observability \
  -only-testing:ObservabilityTests/DashboardViewModelTests

# Run with coverage
xcodebuild test \
  -scheme Observability \
  -enableCodeCoverage YES \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

## Test Structure

### Unit Tests (`ObservabilityTests/`)

#### DashboardViewModelTests
Tests the main dashboard view model:
- Service initialization
- Health count calculations
- Alert management
- Monitoring lifecycle

**Example:**
```swift
@Test("Health count calculation")
func testHealthCount() async {
    let viewModel = await DashboardViewModel()
    // Test logic
}
```

#### AlertModelTests
Tests alert model behavior:
- Alert creation
- Severity display names
- Age calculations
- Age descriptions

#### ServiceStatusTests
Tests service status enum:
- Status operational checks
- Severity mapping
- Display name formatting

#### HTTPClientTests
Tests HTTP client functionality:
- URL building
- Request formatting
- Response parsing

### Snapshot Tests

Visual regression tests for UI components:
- ServiceStatusIndicator snapshots
- AlertRow snapshots
- StatCard snapshots

**Note**: Snapshot tests require a snapshot testing framework like `swift-snapshot-testing`. The current implementation provides the structure.

### UI Tests (`ObservabilityUITests/`)

End-to-end user flow tests:
- Dashboard navigation
- Service detail views
- Alert interactions
- Filter functionality

## Writing Tests

### Unit Test Template

```swift
import Testing
import Foundation
import ObservabilityCore

@available(macOS 14, iOS 17, *)
@Suite("My Feature Tests")
struct MyFeatureTests {
    
    @Test("Test description")
    func testFeature() async {
        // Arrange
        let input = "test"
        
        // Act
        let result = processInput(input)
        
        // Assert
        #expect(result == "expected")
    }
}
```

### Async Testing

```swift
@Test("Async operation")
func testAsyncOperation() async throws {
    let result = try await performAsyncOperation()
    #expect(result != nil)
}
```

### Mocking

For testing with mocks:

```swift
class MockHTTPClient: HTTPClient {
    var mockResponse: Data?
    
    override func request<T>(...) async throws -> T {
        // Return mock data
    }
}
```

## Test Coverage Goals

- **Unit Tests**: > 80% coverage
- **Integration Tests**: Critical paths covered
- **UI Tests**: Main user flows covered
- **Snapshot Tests**: All UI components

## Continuous Integration

Tests run automatically on:
- Pull requests
- Commits to main branch
- Nightly builds

## Best Practices

1. **Test One Thing**: Each test should verify one behavior
2. **Use Descriptive Names**: Test names should describe what they test
3. **Arrange-Act-Assert**: Structure tests clearly
4. **Mock External Dependencies**: Don't rely on network in unit tests
5. **Test Edge Cases**: Include boundary conditions
6. **Keep Tests Fast**: Unit tests should run in milliseconds
7. **Isolate Tests**: Tests should not depend on each other

## Debugging Tests

### In Xcode

1. Set breakpoints in test code
2. Run test with debugger attached
3. Step through code execution
4. Inspect variables and state

### Test Failures

When tests fail:
1. Read error message carefully
2. Check expected vs actual values
3. Verify test setup and teardown
4. Check for timing issues in async tests

## Performance Testing

For performance-critical code:

```swift
@Test("Performance test")
func testPerformance() {
    measure {
        // Code to measure
    }
}
```

## Coverage Reports

Generate coverage reports:

```bash
xcodebuild test \
  -scheme Observability \
  -enableCodeCoverage YES \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# View coverage in Xcode
# Product > Show Code Coverage
```

---

*"Test with confidence, deploy with certainty"* ✨🧪

