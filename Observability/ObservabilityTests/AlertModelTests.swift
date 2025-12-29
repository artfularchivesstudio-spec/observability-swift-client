import XCTest
@testable import ObservabilityCore

class AlertModelTests: XCTestCase {

    func testAlertInitialization() {
        // Test alert initialization
        let alert = ObservabilityCore.Alert(
            title: "Test Alert",
            message: "This is a test alert",
            severity: .info,
            source: ObservabilityCore.Alert.AlertSource(
                serviceName: "Test Service",
                checkType: "health"
            )
        )
        
        XCTAssertEqual(alert.title, "Test Alert")
        XCTAssertEqual(alert.message, "This is a test alert")
        XCTAssertEqual(alert.severity, .info)
    }

    // Add more test cases here...
}
