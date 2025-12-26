//
//  HTTPClient.swift
//  ObservabilityNetworking
//
//  🌍 The Cosmic HTTP Gateway - Where RESTful Dreams Become Reality ✨
//

import Foundation
import ObservabilityCore

/// 🌐 HTTP client for REST API communication
@available(macOS 14, iOS 17, *)
public actor HTTPClient {
    // MARK: - Properties
    private let session: URLSession
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: - Initialization
    public init(session: URLSession = .shared) {
        self.session = session

        // Configure encoder
        encoder.dateEncodingStrategy = .iso8601

        // Configure decoder
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    // MARK: - Generic Request Method
    public func request<T: Decodable>(
        _ endpoint: String,
        method: HTTPMethod = .get,
        baseURL: URL? = nil,
        headers: [String: String] = [:],
        body: Encodable? = nil
    ) async throws -> T {
        let url = try buildURL(endpoint: endpoint, baseURL: baseURL)

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        // Set default headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("observability-client/1.0", forHTTPHeaderField: "User-Agent")

        // Add custom headers
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        // Add body if present
        if let body = body {
            request.httpBody = try encoder.encode(body)
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorData = try? decoder.decode(ErrorResponse.self, from: data)
            throw HTTPError.serverError(
                code: httpResponse.statusCode,
                message: errorData?.message ?? "Unknown error"
            )
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            // Try to decode as generic JSON if specific type fails
            if T.self == [String: Any].self {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                return json as! T
            }
            throw HTTPError.decodingFailed(error)
        }
    }

    // MARK: - Helper Methods
    private func buildURL(endpoint: String, baseURL: URL?) throws -> URL {
        let fullURL: URL

        if let base = baseURL {
            fullURL = base.appendingPathComponent(endpoint)
        } else if let url = URL(string: endpoint) {
            fullURL = url
        } else {
            throw HTTPError.invalidURL(endpoint)
        }

        return fullURL
    }

    // MARK: - Convenience Methods
    public func get<T: Decodable>(
        _ endpoint: String,
        baseURL: URL? = nil,
        headers: [String: String] = [:]
    ) async throws -> T {
        try await request(endpoint, method: .get, baseURL: baseURL, headers: headers)
    }

    public func post<T: Decodable>(
        _ endpoint: String,
        baseURL: URL? = nil,
        headers: [String: String] = [:],
        body: Encodable? = nil
    ) async throws -> T {
        try await request(endpoint, method: .post, baseURL: baseURL, headers: headers, body: body)
    }

    public func put<T: Decodable>(
        _ endpoint: String,
        baseURL: URL? = nil,
        headers: [String: String] = [:],
        body: Encodable? = nil
    ) async throws -> T {
        try await request(endpoint, method: .put, baseURL: baseURL, headers: headers, body: body)
    }

    public func delete(
        _ endpoint: String,
        baseURL: URL? = nil,
        headers: [String: String] = [:]
    ) async throws {
        let _: String = try await request(endpoint, method: .delete, baseURL: baseURL, headers: headers)
    }

    // MARK: - Streaming Support (Server-Sent Events)
    public func streamEvents(from url: URL) -> AsyncStream<StreamEvent> {
        AsyncStream { continuation in
            Task {
                do {
                    var request = URLRequest(url: url)
                    request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
                    request.setValue("observability-client/1.0", forHTTPHeaderField: "User-Agent")
                    
                    let (stream, response) = try await session.bytes(for: request)
                    guard let httpResponse = response as? HTTPURLResponse,
                          (200...299).contains(httpResponse.statusCode) else {
                        continuation.finish()
                        return
                    }

                    var buffer = ""
                    for try await byte in stream {
                        buffer.append(Character(UnicodeScalar(byte)))
                        
                        // Process complete lines (SSE format: "data: {...}\n\n")
                        if buffer.contains("\n\n") {
                            let lines = buffer.components(separatedBy: "\n\n")
                            buffer = lines.last ?? ""
                            
                            for line in lines.dropLast() {
                                if line.hasPrefix("data: ") {
                                    let jsonString = String(line.dropFirst(6)) // Remove "data: " prefix
                                    if let jsonData = jsonString.data(using: .utf8),
                                       let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                                        let event = parseLogEvent(json)
                                        continuation.yield(event)
                                    }
                                }
                            }
                        }
                    }

                    continuation.finish()
                } catch {
                    continuation.finish()
                }
            }
        }
    }
    
    // 🌟 Parse log event from monitoring service format
    private func parseLogEvent(_ json: [String: Any]) -> StreamEvent {
        let id = UUID()
        let type = json["level"] as? String ?? json["type"] as? String ?? "info"
        let timestamp: Date
        
        if let timestampString = json["timestamp"] as? String {
            let formatter = ISO8601DateFormatter()
            timestamp = formatter.date(from: timestampString) ?? Date()
        } else {
            timestamp = Date()
        }
        
        let source = json["source"] as? String ?? "unknown"
        let message = json["message"] as? String ?? ""
        
        // Convert all values to strings for StreamEvent.data
        var data: [String: String] = [:]
        for (key, value) in json {
            if let stringValue = value as? String {
                data[key] = stringValue
            } else {
                data[key] = String(describing: value)
            }
        }
        
        // Ensure message is in data
        if !data.keys.contains("message") {
            data["message"] = message
        }
        
        return StreamEvent(
            id: id,
            type: type,
            timestamp: timestamp,
            data: data,
            source: source
        )
    }
}

// MARK: - Supporting Types

@available(macOS 14, iOS 17, *)
public enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

@available(macOS 14, iOS 17, *)
struct ErrorResponse: Decodable {
    let message: String
    let code: String?
}

// MARK: - Error Handling

@available(macOS 14, iOS 17, *)
public enum HTTPError: Error, LocalizedError {
    case invalidURL(String)
    case invalidResponse
    case serverError(code: Int, message: String)
    case decodingFailed(Error)
    case encodingFailed(Error)

    public var errorDescription: String? {
        switch self {
        case .invalidURL(let url):
            return "Invalid URL: \(url)"
        case .invalidResponse:
            return "Invalid server response"
        case .serverError(let code, let message):
            return "Server error \(code): \(message)"
        case .decodingFailed(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .encodingFailed(let error):
            return "Failed to encode request: \(error.localizedDescription)"
        }
    }
}
