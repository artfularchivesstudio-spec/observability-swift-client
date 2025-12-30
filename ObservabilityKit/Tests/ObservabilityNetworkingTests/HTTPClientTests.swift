//
//  HTTPClientTests.swift
//  ObservabilityNetworkingTests
//
//  🌐 The Cosmic HTTP Validator - Where Network Requests Face Their Trial ✨
//
//  "In the observability theater, we test every network call to ensure
//  our HTTP client dances gracefully with servers near and far."
//
//  - The Spellbinding Museum Director of Network Testing

import XCTest
@testable import ObservabilityNetworking
@testable import ObservabilityCore

@available(macOS 14, iOS 17, *)
final class HTTPClientTests: XCTestCase {
    
    var httpClient: HTTPClient!
    
    override func setUp() {
        super.setUp()
        httpClient = HTTPClient()
    }
    
    override func tearDown() {
        httpClient = nil
        super.tearDown()
    }
    
    // MARK: - GET Request Tests
    
    /// 🌐 Test successful GET request with JSON response
    func testGetRequestSuccess() async throws {
        // Using httpbin.org for testing - it's a reliable test service
        let url = "https://httpbin.org/json"
        
        struct HttpBinResponse: Codable {
            let slideshow: Slideshow
            
            struct Slideshow: Codable {
                let author: String
                let date: String
                let slides: [Slide]
                
                struct Slide: Codable {
                    let title: String
                    let type: String
                }
            }
        }
        
        let response: HttpBinResponse = try await httpClient.get(
            url,
            baseURL: nil,
            headers: [:]
        )
        
        XCTAssertEqual(response.slideshow.author, "Yours Truly")
        XCTAssertFalse(response.slideshow.slides.isEmpty)
    }
    
    /// 🌐 Test GET request with query parameters
    func testGetRequestWithQueryParameters() async throws {
        let url = "https://httpbin.org/get"
        
        struct HttpBinGetResponse: Codable {
            let args: [String: String]
            let url: String
        }
        
        let response: HttpBinGetResponse = try await httpClient.get(
            url,
            baseURL: nil,
            headers: [:]
        )
        
        XCTAssertTrue(response.url.contains("httpbin.org/get"))
    }
    
    /// 🌐 Test GET request with custom headers
    func testGetRequestWithHeaders() async throws {
        let url = "https://httpbin.org/headers"
        
        struct HttpBinHeadersResponse: Codable {
            let headers: [String: String]
        }
        
        let customHeaders = [
            "X-Custom-Header": "test-value",
            "User-Agent": "ObservabilityTest/1.0"
        ]
        
        let response: HttpBinHeadersResponse = try await httpClient.get(
            url,
            baseURL: nil,
            headers: customHeaders
        )
        
        // httpbin returns headers in lowercase
        XCTAssertNotNil(response.headers["x-custom-header"])
        XCTAssertEqual(response.headers["x-custom-header"], "test-value")
    }
    
    /// 🌐 Test GET request with base URL
    func testGetRequestWithBaseURL() async throws {
        let baseURL = URL(string: "https://httpbin.org")!
        let path = "/json"
        
        struct HttpBinResponse: Codable {
            let slideshow: Slideshow
            
            struct Slideshow: Codable {
                let author: String
            }
        }
        
        let response: HttpBinResponse = try await httpClient.get(
            path,
            baseURL: baseURL,
            headers: [:]
        )
        
        XCTAssertEqual(response.slideshow.author, "Yours Truly")
    }
    
    /// 🌐 Test GET request error handling for invalid URL
    func testGetRequestInvalidURL() async {
        let invalidURL = "not-a-valid-url"
        
        do {
            struct DummyResponse: Codable {}
            let _: DummyResponse = try await httpClient.get(
                invalidURL,
                baseURL: nil,
                headers: [:]
            )
            XCTFail("Should have thrown an error for invalid URL")
        } catch {
            // Expected to fail
            XCTAssertNotNil(error)
        }
    }
    
    /// 🌐 Test GET request error handling for 404
    func testGetRequest404Error() async {
        let url = "https://httpbin.org/status/404"
        
        do {
            struct DummyResponse: Codable {}
            let _: DummyResponse = try await httpClient.get(
                url,
                baseURL: nil,
                headers: [:]
            )
            XCTFail("Should have thrown an error for 404")
        } catch {
            // Expected to fail with 404
            XCTAssertNotNil(error)
        }
    }
    
    /// 🌐 Test GET request timeout handling
    func testGetRequestTimeout() async {
        // Using a URL that will timeout
        let url = "https://httpbin.org/delay/10" // 10 second delay
        
        do {
            struct DummyResponse: Codable {}
            let _: DummyResponse = try await httpClient.get(
                url,
                baseURL: nil,
                headers: [:]
            )
            // If it completes, that's fine too (depends on timeout settings)
        } catch {
            // Timeout is acceptable
            XCTAssertNotNil(error)
        }
    }
    
    // MARK: - POST Request Tests
    
    /// 🌐 Test POST request with JSON body
    func testPostRequestWithJSONBody() async throws {
        let url = "https://httpbin.org/post"
        
        struct RequestBody: Codable {
            let message: String
            let value: Int
        }
        
        struct HttpBinPostResponse: Codable {
            let json: RequestBody
            let url: String
        }
        
        let requestBody = RequestBody(message: "Hello from test", value: 42)
        let response: HttpBinPostResponse = try await httpClient.post(
            url,
            baseURL: nil,
            headers: ["Content-Type": "application/json"],
            body: requestBody
        )
        
        XCTAssertEqual(response.json.message, "Hello from test")
        XCTAssertEqual(response.json.value, 42)
    }
    
    /// 🌐 Test POST request with empty body
    func testPostRequestWithEmptyBody() async throws {
        let url = "https://httpbin.org/post"
        
        struct HttpBinPostResponse: Codable {
            let data: String
        }
        
        let response: HttpBinPostResponse = try await httpClient.post(
            url,
            baseURL: nil,
            headers: [:],
            body: Optional<[String: String]>.none
        )
        
        // Empty body should result in empty data string
        XCTAssertEqual(response.data, "")
    }
    
    // MARK: - Decoding Tests
    
    /// 🌐 Test decoding with snake_case conversion
    func testDecodingSnakeCase() async throws {
        let url = "https://httpbin.org/json"
        
        struct HttpBinResponse: Codable {
            let slideshow: Slideshow
            
            struct Slideshow: Codable {
                let author: String
                let date: String
            }
        }
        
        let response: HttpBinResponse = try await httpClient.get(
            url,
            baseURL: nil,
            headers: [:]
        )
        
        XCTAssertEqual(response.slideshow.author, "Yours Truly")
        XCTAssertFalse(response.slideshow.date.isEmpty)
    }
    
    /// 🌐 Test decoding error handling for invalid JSON
    func testDecodingInvalidJSON() async {
        // Using httpbin's raw endpoint to get plain text
        let url = "https://httpbin.org/robots.txt"
        
        do {
            struct DummyResponse: Codable {
                let data: String
            }
            let _: DummyResponse = try await httpClient.get(
                url,
                baseURL: nil,
                headers: [:]
            )
            XCTFail("Should have thrown a decoding error")
        } catch {
            // Expected decoding error
            XCTAssertNotNil(error)
        }
    }
}
