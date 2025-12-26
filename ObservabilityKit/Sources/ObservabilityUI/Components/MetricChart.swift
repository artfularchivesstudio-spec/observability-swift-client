//
//  MetricChart.swift
//  ObservabilityUI
//
//  📈 The Cosmic Metrics Visualizer - Where Data Becomes Art Through Motion and Light ✨
//

import SwiftUI
import Combine
import ObservabilityCore

/// 📊 Real-time metric chart with animated updates
@available(macOS 14, iOS 17, *)
public struct MetricChart: View {
    public let title: String
    public let metricsPublisher: AnyPublisher<MetricPoint, Never>
    public var maxDataPoints: Int = 60
    public var chartType: ChartType = .line

    @State private var dataPoints: [MetricPoint] = []
    @State private var cancellables = Set<AnyCancellable>()

    public init(
        title: String,
        metricsPublisher: AnyPublisher<MetricPoint, Never>,
        maxDataPoints: Int = 60,
        chartType: ChartType = .line
    ) {
        self.title = title
        self.metricsPublisher = metricsPublisher
        self.maxDataPoints = maxDataPoints
        self.chartType = chartType
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                if let last = dataPoints.last {
                    Text("\(String(format: "%.2f", last.value))")
                        .font(.subheadline.monospaced())
                        .foregroundColor(.secondary)
                }
            }

            chartView
                .frame(height: 120)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.secondary.opacity(0.1))
                )

            statisticsView
        }
        .padding()
        .onAppear {
            setupSubscription()
        }
        .onDisappear {
            cancellables.removeAll()
        }
    }

    @ViewBuilder
    private var chartView: some View {
        GeometryReader { geometry in
            ZStack {
                // Grid lines
                VStack(spacing: 0) {
                    ForEach(0..<5) { i in
                        HStack {
                            Rectangle()
                                .fill(Color.secondary.opacity(0.2))
                                .frame(height: 0.5)
                        }
                        if i < 4 {
                            Spacer()
                        }
                    }
                }

                // Chart path
                chartPath(in: geometry)
                    .stroke(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 2
                    )

                // Area fill
                if chartType == .area {
                    chartPath(in: geometry)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.blue.opacity(0.3),
                                    Color.purple.opacity(0.1)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }

                // Data points
                ForEach(Array(dataPoints.enumerated()), id: \.element.timestamp) { index, point in
                    chartPoint(for: point, at: index, in: geometry)
                }
            }
        }
    }

    private func chartPath(in geometry: GeometryProxy) -> Path {
        var path = Path()

        guard !dataPoints.isEmpty else { return path }

        let width = geometry.size.width
        let height = geometry.size.height
        let stepX = width / CGFloat(maxDataPoints - 1)

        let minValue = dataPoints.map { $0.value }.min() ?? 0
        let maxValue = dataPoints.map { $0.value }.max() ?? 1
        let range = maxValue - minValue

        for (index, point) in dataPoints.enumerated() {
            let x = CGFloat(index) * stepX
            let normalizedValue = (point.value - minValue) / (range == 0 ? 1 : range)
            let y = height - (normalizedValue * height)

            let point = CGPoint(x: x, y: y)

            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }

        if chartType == .area {
            path.addLine(to: CGPoint(x: width, y: height))
            path.addLine(to: CGPoint(x: 0, y: height))
            path.closeSubpath()
        }

        return path
    }

    @ViewBuilder
    private func chartPoint(for point: MetricPoint, at index: Int, in geometry: GeometryProxy) -> some View {
        let width = geometry.size.width
        let height = geometry.size.height
        let stepX = width / CGFloat(maxDataPoints - 1)

        let minValue = dataPoints.map { $0.value }.min() ?? 0
        let maxValue = dataPoints.map { $0.value }.max() ?? 1
        let range = maxValue - minValue

        let x = CGFloat(index) * stepX
        let normalizedValue = (point.value - minValue) / (range == 0 ? 1 : range)
        let y = height - (normalizedValue * height)

        Circle()
            .fill(Color.blue)
            .frame(width: 4, height: 4)
            .position(x: x, y: y)
    }

    private var statisticsView: some View {
        HStack(spacing: 16) {
            if let avg = average {
                StatisticView(label: "Avg", value: String(format: "%.2f", avg))
            }

            if let max = max {
                StatisticView(label: "Max", value: String(format: "%.2f", max))
            }

            if let min = min {
                StatisticView(label: "Min", value: String(format: "%.2f", min))
            }

            Spacer()

            Text("+\(dataPoints.count)")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.green.opacity(0.2))
                )
        }
    }

    private var average: Double? {
        guard !dataPoints.isEmpty else { return nil }
        return dataPoints.map { $0.value }.reduce(0, +) / Double(dataPoints.count)
    }

    private var max: Double? {
        guard !dataPoints.isEmpty else { return nil }
        return dataPoints.map { $0.value }.max()
    }

    private var min: Double? {
        guard !dataPoints.isEmpty else { return nil }
        return dataPoints.map { $0.value }.min()
    }

    private func setupSubscription() {
        metricsPublisher
            .receive(on: DispatchQueue.main)
            .sink { metric in
                // Add new data point
                self.dataPoints.append(metric)

                // Keep only the last N points
                if self.dataPoints.count > self.maxDataPoints {
                    self.dataPoints.removeFirst(self.dataPoints.count - self.maxDataPoints)
                }
            }
            .store(in: &cancellables)
    }
}

/// 📊 Simple statistic view component
@available(macOS 14, iOS 17, *)
struct StatisticView: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(value)
                .font(.subheadline.monospaced())
                .foregroundColor(.primary)
        }
    }
}

/// 📈 Chart view types
@available(macOS 14, iOS 17, *)
public enum ChartType {
    case line
    case area
    case bar
    case scatter
}

/// 🏆 Real-time metric gauge
@available(macOS 14, iOS 17, *)
public struct MetricGauge: View {
    public let title: String
    public let value: Double
    public let minValue: Double
    public let maxValue: Double
    public let unit: String

    public init(
        title: String,
        value: Double,
        minValue: Double = 0,
        maxValue: Double = 100,
        unit: String = "%"
    ) {
        self.title = title
        self.value = value
        self.minValue = minValue
        self.maxValue = maxValue
        self.unit = unit
    }

    public var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)

            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 8)

                Circle()
                    .trim(from: 0, to: normalizedValue)
                    .stroke(
                        AngularGradient(
                            colors: gaugeColors,
                            center: .center,
                            startAngle: .degrees(-90),
                            endAngle: .degrees(270)
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut, value: value)

                VStack(spacing: -2) {
                    Text("\(Int(value))\(unit)")
                        .font(.title2.monospaced())
                        .foregroundColor(.primary)

                    Text("of \(Int(maxValue))\(unit)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 120, height: 120)

            HStack {
                Text("\(Int(minValue))\(unit)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text("\(Int(maxValue))\(unit)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }

    private var normalizedValue: Double {
        guard maxValue > minValue else { return 0 }
        let clampedValue = min(max(value, minValue), maxValue)
        return (clampedValue - minValue) / (maxValue - minValue)
    }

    private var gaugeColors: [Color] {
        let percentage = normalizedValue

        if percentage < 0.3 {
            return [.green, .green]
        } else if percentage < 0.6 {
            return [.yellow, .yellow]
        } else if percentage < 0.8 {
            return [.orange, .orange]
        } else {
            return [.red, .red]
        }
    }
}

/// 📊 Metrics dashboard container
@available(macOS 14, iOS 17, *)
public struct MetricsDashboard: View {
    public let title: String
    public let metricsPublisher: AnyPublisher<MetricPoint, Never>
    public let refreshInterval: TimeInterval
    public let onRefresh: (() -> Void)?

    @State private var lastUpdate: Date = Date()
    @State private var refreshTimer: Timer?

    public init(
        title: String,
        metricsPublisher: AnyPublisher<MetricPoint, Never>,
        refreshInterval: TimeInterval = 5.0,
        onRefresh: (() -> Void)? = nil
    ) {
        self.title = title
        self.metricsPublisher = metricsPublisher
        self.refreshInterval = refreshInterval
        self.onRefresh = onRefresh
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()

                // Auto-refresh indicator
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                        .opacity(isAnimationEnabled ? 1 : 0.3)

                    Text("Live")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Button(action: {
                    Task { @MainActor in
                        onRefresh?()
                        lastUpdate = Date()
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption)
                }
                .buttonStyle(.plain)
            }

            // Charts grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                MetricChart(
                    title: "CPU Usage",
                    metricsPublisher: metricsPublisher
                        .filter { $0.label == "cpu" }
                        .eraseToAnyPublisher(),
                    chartType: .line
                )

                MetricChart(
                    title: "Memory",
                    metricsPublisher: metricsPublisher
                        .filter { $0.label == "memory" }
                        .eraseToAnyPublisher(),
                    chartType: .area
                )
            }
            .padding(.top, 8)

            // Last update time
            HStack {
                Spacer()

                Text("Last update: ") +
                Text(lastUpdate, style: .time)
                    .fontWeight(.medium)
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .onAppear {
            setupRefreshTimer()
        }
        .onDisappear {
            refreshTimer?.invalidate()
        }
    }

    private func setupRefreshTimer() {
        let refreshAction = onRefresh
        refreshTimer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { _ in
            Task { @MainActor in
                refreshAction?()
            }
        }
        // Update lastUpdate separately since it's a @State property
        Task { @MainActor in
            lastUpdate = Date()
        }
    }

    private var isAnimationEnabled: Bool {
        refreshTimer?.isValid ?? false
    }
}
