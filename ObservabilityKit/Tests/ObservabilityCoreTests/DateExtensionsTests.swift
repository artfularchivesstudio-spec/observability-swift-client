//
//  DateExtensionsTests.swift
//  ObservabilityCommonTests
//
//  ⏰ The Temporal Validator - Where Time Itself Faces Examination ✨
//

import XCTest
@testable import ObservabilityCore
@testable import ObservabilityCommon

@available(macOS 14, iOS 17, *)
final class DateExtensionsTests: XCTestCase {

    func testFormattedForDisplay() {
        let date = Date().addingTimeInterval(-60) // 1 minute ago
        let formatted = date.formattedForDisplay()

        XCTAssertTrue(formatted.contains("min") || formatted.contains("minute"))
    }

    func testFormattedForDisplayNow() {
        let date = Date()
        let formatted = date.formattedForDisplay()

        XCTAssertTrue(formatted.contains("now") || formatted.isEmpty)
    }

    func testFormattedAsTimestamp() {
        let date = Date(timeIntervalSince1970: 1234567890)
        let formatted = date.formattedAsTimestamp()

        XCTAssertFalse(formatted.isEmpty)
        XCTAssertTrue(formatted.contains(":")) // Should contain time separator
    }

    func testFormattedAsDateTime() {
        let date = Date(timeIntervalSince1970: 1234567890)
        let formatted = date.formattedAsDateTime()

        XCTAssertFalse(formatted.isEmpty)
        XCTAssertTrue(formatted.contains(",")) // Should contain date separator
    }

    func testTimeAgoJustNow() {
        let date = Date().addingTimeInterval(-5) // 5 seconds ago
        let timeAgo = date.timeAgo()

        XCTAssertEqual(timeAgo, "Just now")
    }

    func testTimeAgoMinutes() {
        let date = Date().addingTimeInterval(-180) // 3 minutes ago
        let timeAgo = date.timeAgo()

        XCTAssertTrue(timeAgo.contains("3"))
        XCTAssertTrue(timeAgo.contains("minute"))
    }

    func testTimeAgoHours() {
        let date = Date().addingTimeInterval(-7200) // 2 hours ago
        let timeAgo = date.timeAgo()

        XCTAssertTrue(timeAgo.contains("2"))
        XCTAssertTrue(timeAgo.contains("hour"))
    }

    func testTimeAgoDays() {
        let date = Date().addingTimeInterval(-172800) // 2 days ago
        let timeAgo = date.timeAgo()

        XCTAssertTrue(timeAgo.contains("2"))
        XCTAssertTrue(timeAgo.contains("day"))
    }
}

@available(macOS 14, iOS 17, *)
final class TimeIntervalExtensionsTests: XCTestCase {

    func testFormattedDurationMilliseconds() {
        let interval: TimeInterval = 0.5 // 500ms
        let formatted = interval.formattedDuration()

        XCTAssertEqual(formatted, "500ms")
    }

    func testFormattedDurationSeconds() {
        let interval: TimeInterval = 2.5
        let formatted = interval.formattedDuration()

        XCTAssertEqual(formatted, "2.50s")
    }

    func testFormattedDurationMinutes() {
        let interval: TimeInterval = 150 // 2 minutes 30 seconds
        let formatted = interval.formattedDuration()

        XCTAssertTrue(formatted.contains("2"))
        XCTAssertTrue(formatted.contains("30"))
    }

    func testFormattedDurationHours() {
        let interval: TimeInterval = 3661 // 1 hour 1 minute 1 second
        let formatted = interval.formattedDuration()

        XCTAssertTrue(formatted.contains("1"))
        XCTAssertTrue(formatted.contains("1m"))
    }

    func testFormattedAsMilliseconds() {
        let interval: TimeInterval = 0.123
        let formatted = interval.formattedAsMilliseconds()

        XCTAssertEqual(formatted, "123ms")
    }

    func testFormattedAsMillisecondsZero() {
        let interval: TimeInterval = 0
        let formatted = interval.formattedAsMilliseconds()

        XCTAssertEqual(formatted, "0ms")
    }

    func testFormattedAsUptime() {
        let interval: TimeInterval = 86400 // 1 day
        let formatted = interval.formattedAsUptime()

        XCTAssertFalse(formatted.isEmpty)
    }

    func testFormattedAsUptimeZero() {
        let interval: TimeInterval = 0
        let formatted = interval.formattedAsUptime()

        XCTAssertEqual(formatted, "Unknown")
    }
}
