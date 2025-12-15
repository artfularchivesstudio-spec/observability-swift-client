//
//  WebSocketClient.swift
//  ObservabilityNetworking
//
//  🌐 The Cosmic WebSocket Bridge - Where Real-Time Dreams Flow Through Digital Channels ✨
//

import Foundation
import ObservabilityCore

/// 🌟 WebSocket client actor for thread-safe networking
@available(macOS 14, iOS 17, *)
public actor WebSocketClient {
    // MARK: - State
    private var task: URLSessionWebSocketTask?
    private let session: URLSession
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: - Events
    private let eventContinuation: AsyncStream<StreamEvent>.Continuation
    private let metricContinuation: AsyncStream<MetricPoint>.Continuation
    private let healthContinuation: AsyncStream<HealthCheckResult>.Continuation

    public nonisolated let eventStream: AsyncStream<StreamEvent>
    public nonisolated let metricStream: AsyncStream<MetricPoint>
    public nonisolated let healthStream: AsyncStream<HealthCheckResult>

    // MARK: - Initialization
    public init(session: URLSession = .shared) {
        self.session = session

        var eventContinuation: AsyncStream<StreamEvent>.Continuation!
        self.eventStream = AsyncStream { continuation in
            eventContinuation = continuation
        }
        self.eventContinuation = eventContinuation

        var metricContinuation: AsyncStream<MetricPoint>.Continuation!
        self.metricStream = AsyncStream { continuation in
            metricContinuation = continuation
        }
        self.metricContinuation = metricContinuation

        var healthContinuation: AsyncStream<HealthCheckResult>.Continuation!
        self.healthStream = AsyncStream { continuation in
            healthContinuation = continuation
        }
        self.healthContinuation = healthContinuation
    }

    // MARK: - Connection Management
    public func connect(to endpoint: URL) async throws {
        guard task == nil else {
            throw WebSocketError.alreadyConnected
        }

        var request = URLRequest(url: endpoint)
        request.setValue("observability-client/1.0", forHTTPHeaderField: "User-Agent")
        request.setValue("json", forHTTPHeaderField: "Accept")

        let task = session.webSocketTask(with: request)
        self.task = task

        task.resume()
        startReceiving(task: task)

        // Send initial handshake
        try await sendHandshake()
    }

    public func disconnect() async throws {
        guard let task = task else {
            throw WebSocketError.notConnected
        }

        task.cancel(with: .normalClosure, reason: nil)
        self.task = nil

        eventContinuation.finish()
        metricContinuation.finish()
        healthContinuation.finish()
    }

    public var isConnected: Bool {
        task != nil && task?.closeCode == .invalid
    }

    // MARK: - Message Handling
    private func startReceiving(task: URLSessionWebSocketTask) {
        Task {
            do {
                while task.closeCode == .invalid {
                    let message = try await task.receive()
                    await handleMessage(message)
                }
            } catch {
                await handleError(error)
            }
        }
    }

    private func handleMessage(_ message: URLSessionWebSocketTask.Message) async {
        switch message {
        case .string(let text):
            await handleTextMessage(text)
        case .data(let data):
            await handleDataMessage(data)
        @unknown default:
            break
        }
    }

    private func handleTextMessage(_ text: String) async {
        if let data = text.data(using: .utf8) {
            await handleDataMessage(data)
        }
    }

    private func handleDataMessage(_ data: Data) async {
        // Try to decode as different message types
        if let event = try? decoder.decode(StreamEvent.self, from: data) {
            eventContinuation.yield(event)
        } else if let metric = try? decoder.decode(MetricPoint.self, from: data) {
            metricContinuation.yield(metric)
        } else if let health = try? decoder.decode(HealthCheckResult.self, from: data) {
            healthContinuation.yield(health)
        } else if let generic = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            // Handle generic events
            if let type = generic["type"] as? String {
                let event = StreamEvent(
                    type: type,
                    data: generic.reduce(into: [:]) { result, pair in
                        if let value = pair.value as? String {
                            result[pair.key] = value
                        }
                    },
                    source: "websocket"
                )
                eventContinuation.yield(event)
            }
        }
    }

    private func handleError(_ error: Error) async {
        let event = StreamEvent(
            type: "error",
            data: ["message": error.localizedDescription],
            source: "websocket"
        )
        eventContinuation.yield(event)
    }

    // MARK: - Sending Messages
    public func sendEvent(_ event: StreamEvent) async throws {
        let data = try encoder.encode(event)
        try await send(.data(data))
    }

    public func publishMetrics(_ metrics: [String: MetricValue]) async throws {
        let payload = MetricPayload(type: "metrics", metrics: metrics)
        let data = try encoder.encode(payload)
        try await send(.data(data))
    }

    public func broadcastHealthUpdate(_ result: HealthCheckResult) async throws {
        let data = try encoder.encode(result)
        try await send(.data(data))
    }

    private func sendHandshake() async throws {
        let handshake = Handshake(
            version: "1.0",
            capabilities: ["events", "metrics", "health"]
        )
        let data = try encoder.encode(handshake)
        try await send(.data(data))
    }

    private func send(_ message: URLSessionWebSocketTask.Message) async throws {
        guard let task = task else {
            throw WebSocketError.notConnected
        }

        do {
            try await task.send(message)
        } catch {
            throw WebSocketError.sendFailed(error)
        }
    }

    // MARK: - Ping/Pong
    public func ping() async throws {
        guard let task = task else {
            throw WebSocketError.notConnected
        }

        // Bridge the callback-based ping to async/throwing
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            task.sendPing { error in
                if let error {
                    continuation.resume(throwing: WebSocketError.pingFailed(error))
                } else {
                    continuation.resume()
                }
            }
        }
    }
}

// MARK: - Supporting Types

@available(macOS 14, iOS 17, *)
private struct MetricPayload: Codable {
    init(type: String, metrics: [String : MetricValue]) {
        self.type = type
        self.metrics = metrics
    }
    let type: String
    let metrics: [String: MetricValue]
}

@available(macOS 14, iOS 17, *)
private struct Handshake: Codable {
    let version: String
    let capabilities: [String]
}

// MARK: - Error Handling

@available(macOS 14, iOS 17, *)
public enum WebSocketError: Error, LocalizedError {
    case alreadyConnected
    case notConnected
    case sendFailed(Error)
    case pingFailed(Error)
    case invalidMessage

    public var errorDescription: String? {
        switch self {
        case .alreadyConnected:
            return "WebSocket is already connected"
        case .notConnected:
            return "WebSocket is not connected"
        case .sendFailed(let error):
            return "Failed to send message: \(error.localizedDescription)"
        case .pingFailed(let error):
            return "Ping failed: \(error.localizedDescription)"
        case .invalidMessage:
            return "Invalid message format"
        }
    }
}
