//
//  ErrorDetailView.swift
//  Observability
//
//  🔍 The Cosmic Alert Inspector - Where Digital Mysteries Unfold Their Secrets ✨
//

import SwiftUI
import Combine
import ObservabilityCore

/// 🔍 Comprehensive alert detail view with actions and insights
@available(macOS 14, iOS 17, *)
struct ErrorDetailView: View {
    let alert: ObservabilityCore.Alert
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AlertDetailViewModel

    init(alert: ObservabilityCore.Alert) {
        self.alert = alert
        _viewModel = StateObject(wrappedValue: AlertDetailViewModel(alert: alert))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header Section
                headerSection

                // Alert Message
                messageSection

                // Source Information
                sourceSection

                // Metadata & Tags
                if !alert.metadata.isEmpty || !alert.tags.isEmpty {
                    metadataSection
                }

                // Actions Section
                actionsSection

                // Timeline
                timelineSection
            }
            .padding()
        }
        .navigationTitle("Alert Details")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
            #else
            ToolbarItem(placement: .primaryAction) {
                Button("Done") {
                    dismiss()
                }
            }
            #endif
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                // Severity Icon
                Image(systemName: severityIcon)
                    .font(.system(size: 32))
                    .foregroundColor(severityColor)
                    .frame(width: 48, height: 48)
                    .background(
                        Circle()
                            .fill(severityColor.opacity(0.1))
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(alert.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    HStack(spacing: 8) {
                        Label(alert.severity.displayName, systemImage: severityIcon)
                            .font(.subheadline)
                            .foregroundColor(severityColor)

                        if alert.resolved {
                            Label("Resolved", systemImage: "checkmark.circle.fill")
                                .font(.subheadline)
                                .foregroundColor(.green)
                        } else if alert.acknowledged {
                            Label("Acknowledged", systemImage: "eye.fill")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        } else {
                            Label("Active", systemImage: "exclamationmark.circle.fill")
                                .font(.subheadline)
                                .foregroundColor(.orange)
                        }
                    }
                }

                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }

    // MARK: - Message Section
    private var messageSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .font(.headline)
                .foregroundColor(.secondary)

            Text(alert.message)
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.secondary.opacity(0.05))
        )
    }

    // MARK: - Source Section
    private var sourceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Source Information")
                .font(.headline)
                .foregroundColor(.secondary)

            VStack(spacing: 8) {
                InfoRow(label: "Service", value: alert.source.serviceName, icon: "server.rack")

                InfoRow(label: "Check Type", value: alert.source.checkType, icon: "checkmark.shield")

                if let location = alert.source.location {
                    InfoRow(label: "Location", value: location, icon: "location.fill")
                }

                InfoRow(
                    label: "Timestamp",
                    value: alert.timestamp.formatted(date: .abbreviated, time: .shortened),
                    icon: "clock.fill"
                )

                InfoRow(
                    label: "Age",
                    value: alert.ageDescription,
                    icon: "hourglass"
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }

    // MARK: - Metadata Section
    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !alert.tags.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tags")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    FlowLayout(spacing: 8) {
                        ForEach(Array(alert.tags).sorted(), id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(Color.blue.opacity(0.1))
                                )
                                .foregroundColor(.blue)
                        }
                    }
                }
            }

            if !alert.metadata.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Additional Details")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(Array(alert.metadata.keys).sorted(), id: \.self) { key in
                            HStack(alignment: .top) {
                                Text(key)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(width: 120, alignment: .leading)

                                Text(alert.metadata[key] ?? "")
                                    .font(.caption.monospaced())
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.secondary.opacity(0.05))
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }

    // MARK: - Actions Section
    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Actions")
                .font(.headline)
                .foregroundColor(.secondary)

            VStack(spacing: 12) {
                if !alert.acknowledged {
                    ActionButton(
                        title: "Acknowledge Alert",
                        icon: "eye.fill",
                        color: .blue,
                        isLoading: viewModel.isAcknowledging
                    ) {
                        await viewModel.acknowledgeAlert()
                    }
                }

                if !alert.resolved {
                    ActionButton(
                        title: "Mark as Resolved",
                        icon: "checkmark.circle.fill",
                        color: .green,
                        isLoading: viewModel.isResolving
                    ) {
                        await viewModel.resolveAlert()
                    }
                }

                if alert.acknowledged || alert.resolved {
                    ActionButton(
                        title: "Reopen Alert",
                        icon: "arrow.counterclockwise",
                        color: .orange,
                        isLoading: false
                    ) {
                        await viewModel.reopenAlert()
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }

    // MARK: - Timeline Section
    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Timeline")
                .font(.headline)
                .foregroundColor(.secondary)

            TimelineItem(
                title: "Alert Created",
                timestamp: alert.timestamp,
                icon: "exclamationmark.triangle.fill",
                color: severityColor
            )

            if alert.acknowledged {
                TimelineItem(
                    title: "Alert Acknowledged",
                    timestamp: viewModel.acknowledgedAt ?? alert.timestamp,
                    icon: "eye.fill",
                    color: .blue
                )
            }

            if alert.resolved {
                TimelineItem(
                    title: "Alert Resolved",
                    timestamp: viewModel.resolvedAt ?? alert.timestamp,
                    icon: "checkmark.circle.fill",
                    color: .green
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }

    // MARK: - Computed Properties
    private var severityIcon: String {
        switch alert.severity {
        case .info:
            return "info.circle.fill"
        case .warning:
            return "exclamationmark.triangle.fill"
        case .error:
            return "xmark.circle.fill"
        case .critical:
            return "exclamationmark.octagon.fill"
        }
    }

    private var severityColor: Color {
        switch alert.severity {
        case .info:
            return .blue
        case .warning:
            return .orange
        case .error:
            return .red
        case .critical:
            return .red
        }
    }
}

// MARK: - Supporting Views

/// 📋 Info row component
@available(macOS 14, iOS 17, *)
struct InfoRow: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 20)

            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .leading)

            Text(value)
                .font(.subheadline)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

/// 🎬 Action button component
@available(macOS 14, iOS 17, *)
struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let isLoading: Bool
    let action: () async -> Void

    var body: some View {
        Button {
            Task {
                await action()
            }
        } label: {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: icon)
                        .font(.subheadline)
                }

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.1))
            )
            .foregroundColor(color)
        }
        .disabled(isLoading)
    }
}

/// ⏱️ Timeline item component
@available(macOS 14, iOS 17, *)
struct TimelineItem: View {
    let title: String
    let timestamp: Date
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(color)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.primary)

                Text(timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

/// 🌊 Flow layout for tags
@available(macOS 14, iOS 17, *)
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX,
                                     y: bounds.minY + result.frames[index].minY),
                         proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var frames: [CGRect] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }

            self.size = CGSize(
                width: maxWidth,
                height: currentY + lineHeight
            )
        }
    }
}

// MARK: - View Model

/// 🎯 Alert detail view model for managing alert actions
@available(macOS 14, iOS 17, *)
@MainActor
class AlertDetailViewModel: ObservableObject {
    @Published var isAcknowledging = false
    @Published var isResolving = false
    @Published var acknowledgedAt: Date?
    @Published var resolvedAt: Date?

    private let alert: ObservabilityCore.Alert

    init(alert: ObservabilityCore.Alert) {
        self.alert = alert
        // In a real implementation, you'd fetch these from your backend
        // For now, we'll use placeholder logic
        if alert.acknowledged {
            acknowledgedAt = alert.timestamp.addingTimeInterval(60)
        }
        if alert.resolved {
            resolvedAt = alert.timestamp.addingTimeInterval(300)
        }
    }

    func acknowledgeAlert() async {
        isAcknowledging = true
        defer { isAcknowledging = false }

        // 🎭 The acknowledgment ritual - where we mark our awareness of the digital disturbance
        // In a real implementation, this would call your AlertManaging protocol
        try? await Task.sleep(nanoseconds: 500_000_000) // Simulate network delay

        acknowledgedAt = Date()
        // TODO: Call actual alert management service
        // await alertManager.acknowledgeAlert(alert.id)
    }

    func resolveAlert() async {
        isResolving = true
        defer { isResolving = false }

        // ✨ The resolution ceremony - where digital peace is restored
        try? await Task.sleep(nanoseconds: 500_000_000) // Simulate network delay

        resolvedAt = Date()
        // TODO: Call actual alert management service
        // await alertManager.resolveAlert(alert.id)
    }

    func reopenAlert() async {
        // 🔄 The reopening ritual - when mysteries demand another look
        try? await Task.sleep(nanoseconds: 500_000_000) // Simulate network delay

        acknowledgedAt = nil
        resolvedAt = nil
        // TODO: Call actual alert management service
        // await alertManager.reopenAlert(alert.id)
    }
}

