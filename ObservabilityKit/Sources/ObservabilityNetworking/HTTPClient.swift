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

    // MARK: - Streaming Support
    public func streamEvents(from url: URL) -> AsyncStream<StreamEvent> {
        AsyncStream { continuation in
            Task {
                do {
                    let (stream, response) = try await session.bytes(from: url)
                    guard let httpResponse = response as? HTTPURLResponse,
                          (200...299).contains(httpResponse.statusCode) else {
                        continuation.finish()
                        return
                    }

                    for try await line in stream.lines {
                        guard !line.isEmpty else { continue }

                        if let data = line.data(using: .utf8),
                           let event = try? decoder.decode(StreamEvent.self, from: data) {
                            continuation.yield(event)
                        }
                    }

                    continuation.finish()
                } catch {
                    continuation.finish()
                }
            }
        }
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
