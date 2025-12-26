import XCTest
@testable import ObservabilityCore

class AlertModelTests: XCTestCase {

    var testSuite: XCTestSuite {
        let suite = XCTestSuite(name: "Alert Model Tests")
        // Add test cases to the suite
        suite.addTest(AlertModelTests.testAlertInitialization)
        return suite
    }

    func testAlertInitialization() {
        // Test alert initialization
    }

    // Add more test cases here...
}
