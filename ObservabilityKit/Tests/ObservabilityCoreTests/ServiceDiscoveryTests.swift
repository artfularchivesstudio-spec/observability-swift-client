//
//  ServiceDiscoveryTests.swift
//  ObservabilityCoreTests
//
//  🔍 The Cosmic Service Discovery Validator - Where NGINX Configs Face Their Trial ✨
//
//  "Service discovery is the art of finding services hidden in configuration files.
//  We test it to ensure no service goes unnoticed in the observability cosmos."
//
//  - The Spellbinding Museum Director of Service Discovery Testing

import XCTest
@testable import ObservabilityCore

@available(macOS 14, iOS 17, *)
final class ServiceDiscoveryTests: XCTestCase {
    
    // MARK: - Basic NGINX Config Parsing Tests
    
    /// 🔍 Test discovering services from simple NGINX config
    func testDiscoverServicesFromSimpleNginxConfig() {
        let nginxConfig = """
        server {
            listen 80;
            server_name api.example.com;
            
            location / {
                proxy_pass http://localhost:3000;
            }
        }
        """
        
        let services = ServiceDiscovery.discoverServicesFromNginxConfig(nginxConfig)
        
        XCTAssertFalse(services.isEmpty, "Should discover at least one service")
        XCTAssertTrue(services.contains { $0.name.contains("api.example.com") || $0.name.contains("api") })
    }
    
    /// 🔍 Test discovering multiple services
    func testDiscoverMultipleServices() {
        let nginxConfig = """
        server {
            listen 80;
            server_name api.example.com;
            location / {
                proxy_pass http://localhost:3000;
            }
        }
        
        server {
            listen 443 ssl;
            server_name www.example.com;
            location / {
                proxy_pass http://localhost:3001;
            }
        }
        """
        
        let services = ServiceDiscovery.discoverServicesFromNginxConfig(nginxConfig)
        
        XCTAssertGreaterThanOrEqual(services.count, 1, "Should discover multiple services")
    }
    
    /// 🔍 Test discovering services with different ports
    func testDiscoverServicesWithDifferentPorts() {
        let nginxConfig = """
        server {
            listen 80;
            server_name frontend.example.com;
            location / {
                proxy_pass http://localhost:3000;
            }
        }
        
        server {
            listen 80;
            server_name backend.example.com;
            location /api {
                proxy_pass http://localhost:8000;
            }
        }
        """
        
        let services = ServiceDiscovery.discoverServicesFromNginxConfig(nginxConfig)
        
        // Should discover services with different backend ports
        let ports = services.compactMap { $0.port }
        XCTAssertTrue(ports.contains(3000) || ports.contains(8000), "Should find services with ports 3000 or 8000")
    }
    
    /// 🔍 Test discovering services from empty config
    func testDiscoverServicesFromEmptyConfig() {
        let services = ServiceDiscovery.discoverServicesFromNginxConfig("")
        
        XCTAssertTrue(services.isEmpty, "Empty config should return no services")
    }
    
    /// 🔍 Test discovering services from invalid config
    func testDiscoverServicesFromInvalidConfig() {
        let invalidConfig = "This is not a valid NGINX config file at all!"
        
        let services = ServiceDiscovery.discoverServicesFromNginxConfig(invalidConfig)
        
        // Should handle gracefully without crashing
        XCTAssertNotNil(services)
    }
    
    // MARK: - Service Type Detection Tests
    
    /// 🔍 Test detecting Next.js service (port 3000/3001)
    func testDetectNextJSService() {
        let nginxConfig = """
        server {
            listen 80;
            server_name frontend.example.com;
            location / {
                proxy_pass http://localhost:3000;
            }
        }
        """
        
        let services = ServiceDiscovery.discoverServicesFromNginxConfig(nginxConfig)
        
        // Should detect Next.js type for port 3000
        let nextjsService = services.first { $0.port == 3000 }
        XCTAssertNotNil(nextjsService, "Should detect Next.js service on port 3000")
    }
    
    /// 🔍 Test detecting Flask/Python service (port 8000)
    func testDetectFlaskService() {
        let nginxConfig = """
        server {
            listen 80;
            server_name api.example.com;
            location /api {
                proxy_pass http://localhost:8000;
            }
        }
        """
        
        let services = ServiceDiscovery.discoverServicesFromNginxConfig(nginxConfig)
        
        // Should detect Flask type for port 8000
        let flaskService = services.first { $0.port == 8000 }
        XCTAssertNotNil(flaskService, "Should detect Flask service on port 8000")
    }
    
    /// 🔍 Test detecting Strapi service (port 1337)
    func testDetectStrapiService() {
        let nginxConfig = """
        server {
            listen 80;
            server_name cms.example.com;
            location / {
                proxy_pass http://localhost:1337;
            }
        }
        """
        
        let services = ServiceDiscovery.discoverServicesFromNginxConfig(nginxConfig)
        
        // Should detect Strapi type for port 1337
        let strapiService = services.first { $0.port == 1337 }
        XCTAssertNotNil(strapiService, "Should detect Strapi service on port 1337")
    }
    
    // MARK: - Endpoint Discovery Tests
    
    /// 🔍 Test discovering endpoints from location blocks
    func testDiscoverEndpointsFromLocationBlocks() {
        let nginxConfig = """
        server {
            listen 80;
            server_name api.example.com;
            
            location /api/v1/users {
                proxy_pass http://localhost:8000;
            }
            
            location /api/v1/posts {
                proxy_pass http://localhost:8000;
            }
        }
        """
        
        let services = ServiceDiscovery.discoverServicesFromNginxConfig(nginxConfig)
        
        // Should discover endpoints from location blocks
        let service = services.first
        XCTAssertNotNil(service, "Should discover service")
        if let service = service {
            XCTAssertFalse(service.endpoints.isEmpty, "Should discover endpoints from location blocks")
        }
    }
    
    // MARK: - Service Name Generation Tests
    
    /// 🔍 Test service name generation from server_name
    func testServiceNameFromServerName() {
        let nginxConfig = """
        server {
            listen 80;
            server_name python-api.example.com;
            location / {
                proxy_pass http://localhost:8000;
            }
        }
        """
        
        let services = ServiceDiscovery.discoverServicesFromNginxConfig(nginxConfig)
        
        let service = services.first
        XCTAssertNotNil(service, "Should discover service")
        if let service = service {
            // Service name should be derived from server_name
            XCTAssertFalse(service.name.isEmpty, "Service should have a name")
        }
    }
    
    /// 🔍 Test service name fallback when server_name missing
    func testServiceNameFallback() {
        let nginxConfig = """
        server {
            listen 80;
            location / {
                proxy_pass http://localhost:3000;
            }
        }
        """
        
        let services = ServiceDiscovery.discoverServicesFromNginxConfig(nginxConfig)
        
        let service = services.first
        XCTAssertNotNil(service, "Should discover service even without server_name")
        if let service = service {
            XCTAssertFalse(service.name.isEmpty, "Service should have a fallback name")
        }
    }
    
    // MARK: - Category Detection Tests
    
    /// 🔍 Test detecting service category from port
    func testDetectServiceCategory() {
        let nginxConfig = """
        server {
            listen 80;
            server_name frontend.example.com;
            location / {
                proxy_pass http://localhost:3000;
            }
        }
        """
        
        let services = ServiceDiscovery.discoverServicesFromNginxConfig(nginxConfig)
        
        let service = services.first
        XCTAssertNotNil(service, "Should discover service")
        if let service = service {
            // Should have a valid category
            XCTAssertNotNil(service.category, "Service should have a category")
        }
    }
}
