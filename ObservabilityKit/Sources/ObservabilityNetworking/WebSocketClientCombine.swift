//
//  WebSocketClientCombine.swift
//  ObservabilityNetworking
//
//  🌐 The Cosmic Combine Gateway - Where Reactive Streams Flow Like Stardust ✨
//

import Foundation
import Combine
import ObservabilityCore

/// 🌟 WebSocket client using Combine for reactive stream handling
@available(macOS 14, iOS 17, *)
@MainActor
public final class WebSocketCombineClient: ObservableObject {
    // MARK: - Published States
    @Published public private(set) var isConnected = false
    @Published public private(set) var lastError: Error?
    @Published public private(set) var connectionState: ConnectionState = .disconnected

    // MARK: - Subjects for Event Streams
    private let eventSubject = PassthroughSubject<StreamEvent, Never>()
    private let metricSubject = PassthroughSubject<MetricPoint, Never>()
    private let healthSubject = PassthroughSubject<HealthCheckResult, Never>()

    public var eventPublisher: AnyPublisher<StreamEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    public var metricPublisher: AnyPublisher<MetricPoint, Never> {
        metricSubject.eraseToAnyPublisher()
    }

    public var healthPublisher: AnyPublisher<HealthCheckResult, Never> {
        healthSubject.eraseToAnyPublisher()
    }

    // MARK: - Private State
    private var task: URLSessionWebSocketTask?
    private let session: URLSession
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private var cancellables = Set<AnyCancellable>()
    nonisolated(unsafe) private var pingTimer: Timer?
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 5
    private let reconnectDelay = 1.0

    // MARK: - Initialization
    public init(session: URLSession = .shared) {
        self.session = session
        setupPingTimer()
    }

    deinit {
        pingTimer?.invalidate()
        // Note: disconnect() is @MainActor, but deinit is nonisolated
        // We can't safely call @MainActor methods from deinit
        // The timer invalidation is sufficient for cleanup
    }

    // MARK: - Connection Management
    public func connect(to endpoint: URL) async throws {
        guard !isConnected else {
            throw WebSocketError.alreadyConnected
        }

        var request = URLRequest(url: endpoint)
        request.setValue("observability-client/1.0", forHTTPHeaderField: "User-Agent")
        request.setValue("observability.client.v1", forHTTPHeaderField: "Sec-WebSocket-Protocol")

        let task = session.webSocketTask(with: request)
        self.task = task

        // Update state
        connectionState = .connecting
        task.resume()

        // Start receiving messages
        startReceiving()

        // Send handshake
        try await sendHandshake()

        // Update connected state
        connectionState = .connected
        isConnected = true
        reconnectAttempts = 0

        // Notify connection
        let event = StreamEvent(
            type: "connection",
            data: ["status": "connected", "endpoint": endpoint.absoluteString],
            source: "websocket"
        )
        eventSubject.send(event)
    }

    public func disconnect() {
        guard isConnected else { return }

        connectionState = .disconnecting
        task?.cancel(with: .normalClosure, reason: nil)
        task = nil

        connectionState = .disconnected
        isConnected = false

        // Clear cancellables
        cancellables.removeAll()

        // Notify disconnection
        let event = StreamEvent(
            type: "connection",
            data: ["status": "disconnected"],
            source: "websocket"
        )
        eventSubject.send(event)
    }

    // MARK: - Message Handling
    private func startReceiving() {
        guard let task = task else { return }

        Task {
            do {
                for try await message in task.messages {
                    handleMessage(message)
                }
            } catch {
                await handleError(error)
            }
        }
    }

    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .string(let text):
            handleTextMessage(text)
        case .data(let data):
            handleDataMessage(data)
        @unknown default:
            break
        }
    }

    private func handleTextMessage(_ text: String) {
        guard let data = text.data(using: .utf8) else {
            lastError = WebSocketError.invalidMessage
            return
        }
        handleDataMessage(data)
    }

    private func handleDataMessage(_ data: Data) {
        do {
            // Try different message types
            if let event = try? decoder.decode(StreamEvent.self, from: data) {
                eventSubject.send(event)
            } else if let metric = try? decoder.decode(MetricPoint.self, from: data) {
                metricSubject.send(metric)
            } else if let health = try? decoder.decode(HealthCheckResult.self, from: data) {
                healthSubject.send(health)
            } else if let generic = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let type = generic["type"] as? String {
                // Handle generic events
                let eventData = generic.compactMapValues { value in
                    String(describing: value)
                }
                let event = StreamEvent(
                    type: type,
                    data: eventData,
                    source: "websocket"
                )
                eventSubject.send(event)
            }
        } catch {
            lastError = error
        }
    }

    @MainActor
    private func handleError(_ error: Error) {
        lastError = error

        // Notify error
        let event = StreamEvent(
            type: "error",
            data: ["message": error.localizedDescription],
            source: "websocket"
        )
        eventSubject.send(event)

        // Attempt reconnection if appropriate
        if let urlError = error as? URLError, urlError.code == .networkConnectionLost {
            attemptReconnect()
        }
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
        guard let task = task, isConnected else {
            throw WebSocketError.notConnected
        }

        do {
            try await task.send(message)
        } catch {
            throw WebSocketError.sendFailed(error)
        }
    }

    // MARK: - Ping/Pong
    private func setupPingTimer() {
        pingTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            Task { [weak self] in
                await self?.sendPing()
            }
        }
    }

    private func sendPing() async {
        guard let task = task, isConnected else { return }

        do {
            // Bridge callback-based API to async to avoid missing handler error
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                task.sendPing { error in
                    if let error {
                        continuation.resume(throwing: WebSocketError.pingFailed(error))
                    } else {
                        continuation.resume()
                    }
                }
            }
        } catch {
            await handleError(error)
        }
    }

    // MARK: - Reconnection Logic
    private func attemptReconnect() {
        guard reconnectAttempts < maxReconnectAttempts else { return }

        reconnectAttempts += 1
        connectionState = .reconnecting

        let delay = pow(reconnectDelay, Double(reconnectAttempts))

        Task {
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))

            // Attempt reconnection
            // Note: In real implementation, store the original endpoint
        }
    }
}

// MARK: - Supporting Types

@available(macOS 14, iOS 17, *)
public extension WebSocketCombineClient {
    enum ConnectionState {
        case disconnected
        case connecting
        case connected
        case disconnecting
        case reconnecting
    }
}

// MARK: - URLSession Extensions

@available(macOS 14, iOS 17, *)
private extension URLSessionWebSocketTask {
    struct MessageIterator: AsyncSequence {
        typealias Element = URLSessionWebSocketTask.Message

        let task: URLSessionWebSocketTask

        func makeAsyncIterator() -> AsyncIterator {
            AsyncIterator(task: task)
        }

        struct AsyncIterator: AsyncIteratorProtocol {
            let task: URLSessionWebSocketTask

            mutating func next() async throws -> URLSessionWebSocketTask.Message? {
                return try await withCheckedThrowingContinuation { continuation in
                    task.receive { result in
                        continuation.resume(with: result)
                    }
                }
            }
        }
    }

    var messages: MessageIterator {
        MessageIterator(task: self)
    }
}

// MARK: - Local payloads matching the actor-based client

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
