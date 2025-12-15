//
//  AlertTests.swift
//  ObservabilityCoreTests
//
//  🚨 The Cosmic Alert Examiner - Where Warnings Face Their Trial ✨
//

import XCTest
@testable import ObservabilityCore
@testable import ObservabilityCommon

@available(macOS 14, iOS 17, *)
final class AlertTests: XCTestCase {

    // MARK: - Alert Severity Tests

    func testAlertSeverityDisplayNames() {
        XCTAssertEqual(AlertSeverity.info.displayName, "Info")
        XCTAssertEqual(AlertSeverity.warning.displayName, "Warning")
        XCTAssertEqual(AlertSeverity.error.displayName, "Error")
        XCTAssertEqual(AlertSeverity.critical.displayName, "Critical")
    }

    func testAlertSeverityIcons() {
        XCTAssertEqual(AlertSeverity.info.icon, "ℹ️")
        XCTAssertEqual(AlertSeverity.warning.icon, "⚠️")
        XCTAssertEqual(AlertSeverity.error.icon, "❌")
        XCTAssertEqual(AlertSeverity.critical.icon, "🚨")
    }

    func testAlertSeverityColors() {
        XCTAssertEqual(AlertSeverity.info.colorHex, "#3498db")
        XCTAssertEqual(AlertSeverity.warning.colorHex, "#f39c12")
        XCTAssertEqual(AlertSeverity.error.colorHex, "#e74c3c")
        XCTAssertEqual(AlertSeverity.critical.colorHex, "#c0392b")
    }

    func testAlertSeveritySoundNames() {
        XCTAssertNil(AlertSeverity.info.soundName)
        XCTAssertEqual(AlertSeverity.warning.soundName, "warning.aiff")
        XCTAssertEqual(AlertSeverity.error.soundName, "error.aiff")
        XCTAssertEqual(AlertSeverity.critical.soundName, "critical.aiff")
    }

    // MARK: - Alert Tests

    func testAlertInitialization() {
        let alert = Alert(
            title: "Test Alert",
            message: "This is a test alert",
            severity: .warning,
            source: Alert.AlertSource(
                serviceName: "Test Service",
                checkType: "test_check"
            ),
            tags: ["test", "demo"],
            metadata: ["key": "value"]
        )

        XCTAssertEqual(alert.title, "Test Alert")
        XCTAssertEqual(alert.message, "This is a test alert")
        XCTAssertEqual(alert.severity, .warning)
        XCTAssertFalse(alert.acknowledged)
        XCTAssertFalse(alert.resolved)
        XCTAssertEqual(alert.tags.count, 2)
        XCTAssertEqual(alert.metadata["key"], "value")
    }

    func testAlertAgeCalculation() {
        let fiveMinutesAgo = Date().addingTimeInterval(-300)
        let alert = Alert(
            title: "Old Alert",
            message: "This alert is 5 minutes old",
            severity: .info,
            source: Alert.AlertSource(serviceName: "Test", checkType: "test"),
            timestamp: fiveMinutesAgo
        )

        XCTAssertEqual(alert.age, 300, accuracy: 0.1)
        XCTAssertTrue(alert.ageDescription.contains("min"))
    }

    func testAlertSourceProperties() {
        let serviceId = UUID()
        let source = Alert.AlertSource(
            serviceId: serviceId,
            serviceName: "PostgreSQL",
            checkType: "connection_test",
            location: "us-east-1"
        )

        XCTAssertEqual(source.serviceId, serviceId)
        XCTAssertEqual(source.serviceName, "PostgreSQL")
        XCTAssertEqual(source.checkType, "connection_test")
        XCTAssertEqual(source.location, "us-east-1")
    }

    // MARK: - Alert Stats Tests

    func testAlertStatsInitialization() {
        let stats = AlertStats(
            totalCount: 42,
            bySeverity: [.warning: 3, .critical: 2],
            byService: ["web": 5, "db": 2],
            recentCount: 10,
            acknowledgedCount: 8,
            unresolvedCount: 34
        )

        XCTAssertEqual(stats.totalCount, 42)
        XCTAssertEqual(stats.bySeverity[.warning], 3)
        XCTAssertEqual(stats.byService["web"], 5)
        XCTAssertEqual(stats.recentCount, 10)
        XCTAssertEqual(stats.acknowledgedCount, 8)
        XCTAssertEqual(stats.unresolvedCount, 34)
    }

    func testAlertStatsEmpty() {
        let stats = AlertStats()

        XCTAssertEqual(stats.totalCount, 0)
        XCTAssertTrue(stats.bySeverity.isEmpty)
        XCTAssertTrue(stats.byService.isEmpty)
        XCTAssertEqual(stats.recentCount, 0)
        XCTAssertEqual(stats.acknowledgedCount, 0)
        XCTAssertEqual(stats.unresolvedCount, 0)
    }

    // MARK: - Notification Preferences Tests

    func testNotificationPreferencesDefaults() {
        let prefs = NotificationPreferences()

        XCTAssertTrue(prefs.enabled)
        XCTAssertFalse(prefs.criticalOnly)
        XCTAssertNil(prefs.doNotDisturbUntil)
        XCTAssertTrue(prefs.soundEnabled)
        XCTAssertTrue(prefs.badgesEnabled)
        XCTAssertTrue(prefs.services.isEmpty)
        XCTAssertTrue(prefs.shouldNotify)
    }

    func testNotificationPreferencesDoNotDisturb() {
        let futureDate = Date().addingTimeInterval(3600)
        let prefs = NotificationPreferences(
            enabled: true,
            doNotDisturbUntil: futureDate
        )

        XCTAssertFalse(prefs.shouldNotify)
    }

    func testNotificationPreferencesDisabled() {
        let prefs = NotificationPreferences(enabled: false)

        XCTAssertFalse(prefs.shouldNotify)
    }

    func testNotificationPreferencesCriticalOnly() {
        let prefs = NotificationPreferences(criticalOnly: true)

        XCTAssertTrue(prefs.criticalOnly)
    }

    // MARK: - Alert Rule Tests

    func testAlertRuleInitialization() {
        let rule = AlertRule(
            name: "High CPU",
            enabled: true,
            conditions: [
                AlertRule.Condition(
                    metric: "cpu_usage",
                    operator: .greaterThan,
                    threshold: 80,
                    duration: 300
                )
            ],
            actions: [
                .sendAlert(Alert(
                    title: "CPU Alert",
                    message: "High CPU usage",
                    severity: .warning,
                    source: Alert.AlertSource(serviceName: "server", checkType: "cpu")
                ))
            ]
        )

        XCTAssertEqual(rule.name, "High CPU")
        XCTAssertTrue(rule.enabled)
        XCTAssertEqual(rule.conditions.count, 1)
        XCTAssertEqual(rule.actions.count, 1)
    }

    func testAlertRuleConditionProperties() {
        let condition = AlertRule.Condition(
            metric: "memory_usage",
            operator: .lessThanOrEqual,
            threshold: 90.5,
            duration: 60
        )

        XCTAssertEqual(condition.metric, "memory_usage")
        XCTAssertEqual(condition.operator, .lessThanOrEqual)
        XCTAssertEqual(condition.threshold, 90.5)
        XCTAssertEqual(condition.duration, 60)
    }

    func testAlertRuleOperators() {
        let operators: [AlertRule.Condition.Operator] = [
            .greaterThan,
            .lessThan,
            .equals,
            .notEquals,
            .greaterThanOrEqual,
            .lessThanOrEqual
        ]

        XCTAssertEqual(operators.count, 6)
    }

    func testAlertRuleActions() {
        let sendAction: AlertRule.Action = .sendAlert(Alert(
            title: "Test",
            message: "Test",
            severity: .info,
            source: Alert.AlertSource(serviceName: "test", checkType: "test")
        ))

        let webhookAction: AlertRule.Action = .webhook(
            url: URL(string: "https://example.com/webhook")!,
            payload: ["key": "value"]
        )

        let logAction: AlertRule.Action = .log(
            severity: "ERROR",
            message: "Something happened"
        )

        let execAction: AlertRule.Action = .execute("/usr/local/bin/script.sh")

        // Verify actions can be created
        switch sendAction {
        case .sendAlert(let alert):
            XCTAssertEqual(alert.title, "Test")
        default:
            XCTFail("Wrong action type")
        }

        switch webhookAction {
        case .webhook(let url, let payload):
            XCTAssertEqual(url.absoluteString, "https://example.com/webhook")
            XCTAssertEqual(payload["key"], "value")
        default:
            XCTFail("Wrong action type")
        }

        switch logAction {
        case .log(let severity, let message):
            XCTAssertEqual(severity, "ERROR")
            XCTAssertEqual(message, "Something happened")
        default:
            XCTFail("Wrong action type")
        }

        switch execAction {
        case .execute(let command):
            XCTAssertEqual(command, "/usr/local/bin/script.sh")
        default:
            XCTFail("Wrong action type")
        }
    }
}
