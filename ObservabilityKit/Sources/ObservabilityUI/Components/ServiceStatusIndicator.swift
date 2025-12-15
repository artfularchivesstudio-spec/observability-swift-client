//
//  ServiceStatusIndicator.swift
//  ObservabilityUI
//
//  🎨 The Cosmic Status Visualizer - Where Service Health Becomes Visual Poetry ✨
//

import SwiftUI
import ObservabilityCore

/// 🌟 Service status indicator with animated transitions
@available(macOS 14, iOS 17, *)
public struct ServiceStatusIndicator: View {
    public let status: ServiceStatus
    public let showLabel: Bool

    @State private var isAnimating = false

    public init(
        status: ServiceStatus,
        showLabel: Bool = true
    ) {
        self.status = status
        self.showLabel = showLabel
    }

    public var body: some View {
        HStack(spacing: 8) {
            indicatorCircle

            if showLabel {
                Text(status.description)
                    .font(.caption)
                    .foregroundColor(textColor)
                    .transition(.opacity)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).repeatForever()) {
                isAnimating = true
            }
        }
    }

    @ViewBuilder
    private var indicatorCircle: some View {
        Circle()
            .fill(indicatorColor)
            .frame(width: 12, height: 12)
            .overlay {
                Circle()
                    .stroke(indicatorColor.opacity(0.3), lineWidth: 2)
                    .scaleEffect(isAnimating ? 1.5 : 1.0)
                    .opacity(isAnimating ? 0 : 1)
            }
            .animation(.easeInOut(duration: 1.5).repeatForever(), value: isAnimating)
    }

    private var indicatorColor: Color {
        switch status {
        case .operational:
            return .green
        case .degraded:
            return .yellow
        case .down:
            return .red
        case .maintenance:
            return .blue
        case .unknown:
            return .gray
        }
    }

    private var textColor: Color {
        switch status {
        case .operational:
            return .green
        case .degraded:
            return .yellow
        case .down:
            return .red
        case .maintenance:
            return .blue
        case .unknown:
            return .gray
        }
    }
}

/// 🎨 Service card with status and quick actions
@available(macOS 14, iOS 17, *)
public struct ServiceCard: View {
    public let service: ServiceInfo
    public let health: HealthCheckResult?
    public let onTap: (() -> Void)?

    @State private var isPressed = false

    public init(
        service: ServiceInfo,
        health: HealthCheckResult? = nil,
        onTap: (() -> Void)? = nil
    ) {
        self.service = service
        self.health = health
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3)) {
                isPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPressed = false
                    onTap?()
                }
            }
        }) {
            cardContent
        }
        .buttonStyle(ServiceCardButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                iconView

                VStack(alignment: .leading, spacing: 2) {
                    Text(service.name)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(service.type.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if let port = service.port {
                    Text("• \(port)")
                        .font(.caption2.monospaced())
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(4)
                }
            }

            if let health = health {
                Divider()

                HStack {
                    ServiceStatusIndicator(status: health.status, showLabel: false)

                    Text("\(Int(health.responseTime * 1000))ms")
                        .font(.caption.monospaced())
                        .foregroundColor(.secondary)

                    Spacer()

                    Text(health.timestamp, style: .relative)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)

                    Text("Checking...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }

    @ViewBuilder
    private var iconView: some View {
        if let icon = service.icon {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Color(service.category.color))
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(Color(service.category.color).opacity(0.1))
                )
        } else {
            Circle()
                .fill(Color(service.category.color))
                .frame(width: 32, height: 32)
                .overlay {
                    Text(service.name.prefix(1).uppercased())
                        .font(.caption.bold())
                        .foregroundColor(.white)
                }
        }
    }
}

/// 🎭 Custom button style for service cards
@available(macOS 14, iOS 17, *)
struct ServiceCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

/// 📊 Service grid layout with adaptive columns
@available(macOS 14, iOS 17, *)
public struct ServiceGrid: View {
    public let services: [ServiceInfo]
    public let healthResults: [UUID: HealthCheckResult]
    public let onServiceTap: (ServiceInfo) -> Void

    public init(
        services: [ServiceInfo],
        healthResults: [UUID: HealthCheckResult] = [:],
        onServiceTap: @escaping (ServiceInfo) -> Void
    ) {
        self.services = services
        self.healthResults = healthResults
        self.onServiceTap = onServiceTap
    }

    public var body: some View {
        LazyVGrid(columns: adaptiveColumns, spacing: 16) {
            ForEach(services, id: \.id) { service in
                ServiceCard(
                    service: service,
                    health: healthResults[service.id],
                    onTap: { onServiceTap(service) }
                )
            }
        }
    }

    private var adaptiveColumns: [GridItem] {
        [
            GridItem(.adaptive(minimum: 280, maximum: 400), spacing: 16)
        ]
    }
}

/// 🎯 Service status filter buttons
@available(macOS 14, iOS 17, *)
public struct StatusFilterButton: View {
    public let label: String
    public let count: Int
    public let isSelected: Bool
    public let action: () -> Void

    public init(
        label: String,
        count: Int,
        isSelected: Bool,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.count = count
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(label)
                    .font(.subheadline)

                Text("\(count)")
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(isSelected ? Color.white : Color.secondary.opacity(0.2))
                    )
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.blue : Color.clear)
                    .overlay(
                        Capsule()
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}
