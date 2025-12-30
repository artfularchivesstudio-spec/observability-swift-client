//
//  ServiceDiscovery.swift
//  ObservabilityCore
//
//  🔍 The Cosmic Service Discovery Oracle - Where NGINX Configs Reveal Hidden Services ✨
//
//  "In the realm of infrastructure, services hide in configuration files.
//  This utility extracts them, transforming NGINX server blocks into observable services."
//
//  - The Spellbinding Museum Director of Service Discovery

import Foundation

/// 🔍 Service discovery utilities for parsing infrastructure configurations
@available(macOS 14, iOS 17, *)
public struct ServiceDiscovery {
    
    /// 🌐 Parse NGINX config to discover services and endpoints
    /// - Parameter config: NGINX configuration file content
    /// - Returns: Array of discovered ServiceInfo objects
    public static func discoverServicesFromNginxConfig(_ config: String) -> [ServiceInfo] {
        var services: [ServiceInfo] = []
        var currentServer: (name: String, port: Int?, serverName: String?, locations: [(path: String, proxyPass: String?)])? = nil
        
        let lines = config.components(separatedBy: .newlines)
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // Detect server block start
            if trimmed.hasPrefix("server {") || trimmed == "server {" {
                if let server = currentServer {
                    services.append(createServiceFromServer(server))
                }
                currentServer = (name: "Unknown", port: nil, serverName: nil, locations: [])
            }
            
            // Extract server_name - take first domain only and clean it up
            if let serverName = extractValue(from: trimmed, pattern: #"server_name\s+([^;]+);"#) {
                let trimmedName = serverName.trimmingCharacters(in: .whitespaces)
                // Extract first domain from server_name (e.g., "api-router.cloud www.api-router.cloud" -> "api-router.cloud")
                // Also handle cases like "api-router.cloud;" or "api-router.cloud www.api-router.cloud;"
                let cleanedName = trimmedName
                    .components(separatedBy: .whitespaces)
                    .first?
                    .trimmingCharacters(in: CharacterSet(charactersIn: ";"))
                    ?? trimmedName.trimmingCharacters(in: CharacterSet(charactersIn: ";"))
                
                currentServer?.serverName = cleanedName
                if currentServer?.name == "Unknown" {
                    currentServer?.name = cleanedName
                }
            }
            
            // Extract listen port
            if let listenValue = extractValue(from: trimmed, pattern: #"listen\s+(\d+)"#) {
                if let port = Int(listenValue) {
                    currentServer?.port = port
                }
            }
            
            // Extract location blocks
            if trimmed.hasPrefix("location") {
                if let locationPath = extractValue(from: trimmed, pattern: #"location\s+([^{]+)"#) {
                    let path = locationPath.trimmingCharacters(in: .whitespaces)
                    var proxyPass: String? = nil
                    
                    // Look ahead for proxy_pass in next few lines
                    if let currentIndex = lines.firstIndex(of: line), currentIndex < lines.count - 5 {
                        for i in (currentIndex + 1)...min(currentIndex + 10, lines.count - 1) {
                            let nextLine = lines[i].trimmingCharacters(in: .whitespaces)
                            if nextLine.hasPrefix("proxy_pass") {
                                proxyPass = extractValue(from: nextLine, pattern: #"proxy_pass\s+([^;]+);"#)
                                break
                            }
                            if nextLine == "}" { break }
                        }
                    }
                    
                    currentServer?.locations.append((path: path, proxyPass: proxyPass))
                }
            }
            
            // Detect server block end
            if trimmed == "}" && currentServer != nil {
                if let server = currentServer {
                    services.append(createServiceFromServer(server))
                }
                currentServer = nil
            }
        }
        
        // Add final server if exists
        if let server = currentServer {
            services.append(createServiceFromServer(server))
        }
        
        // Only add NGINX as a service if we didn't discover any server blocks
        // (to avoid duplicate entries)
        if services.isEmpty {
            services.append(ServiceInfo(
                name: "NGINX",
                type: .nginx,
                port: 80,
                baseURL: URL(string: "http://localhost"),
                category: .infrastructure,
                description: "Web server and reverse proxy",
                icon: "network",
                tags: ["production", "infrastructure"]
            ))
        }
        
        return services
    }
    
    /// 🔧 Extract value using regex pattern
    private static func extractValue(from line: String, pattern: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]),
              let match = regex.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.utf16.count)),
              match.numberOfRanges > 1,
              let range = Range(match.range(at: 1), in: line) else {
            return nil
        }
        return String(line[range])
    }
    
    /// 🎨 Create ServiceInfo from discovered server block - The naming oracle 🎭
    private static func createServiceFromServer(_ server: (name: String, port: Int?, serverName: String?, locations: [(path: String, proxyPass: String?)])) -> ServiceInfo {
        let serverName = server.serverName ?? server.name
        
        // 🌟 Generate meaningful service name based on port, server_name, and proxy destinations
        let serviceName: String
        if let port = server.port {
            // Check if this is an HTTP redirect server (port 80 -> 443)
            let hasRedirect = server.locations.isEmpty && serverName != "Unknown"
            if hasRedirect && port == 80 {
                serviceName = "\(serverName) (HTTP → HTTPS)"
            } else if port == 443 {
                // HTTPS server - use server_name or create descriptive name
                if serverName != "Unknown" {
                    serviceName = serverName
                } else {
                    serviceName = "HTTPS Server"
                }
            } else {
                // Other ports - use server_name with port
                if serverName != "Unknown" {
                    serviceName = "\(serverName):\(port)"
                } else {
                    serviceName = "Service on Port \(port)"
                }
            }
        } else {
            // No port - use server_name or generic name
            if serverName != "Unknown" {
                serviceName = serverName
            } else {
                serviceName = "NGINX Server"
            }
        }
        
        let baseURLString: String
        if let port = server.port {
            let scheme = port == 443 ? "https" : "http"
            baseURLString = "\(scheme)://\(serverName):\(port)"
        } else {
            baseURLString = "http://\(serverName)"
        }
        
        // Create endpoints from location blocks
        var endpoints: [ServiceEndpoint] = []
        var detectedBackendType: String? = nil
        
        for location in server.locations {
            let method = location.proxyPass != nil ? "GET" : "GET" // Default to GET, could be enhanced
            
            // Extract backend service type from proxy_pass
            if let proxyPass = location.proxyPass {
                // Check proxy_pass for common backend patterns
                if proxyPass.contains(":3000") || proxyPass.contains(":3001") {
                    detectedBackendType = "Next.js"
                } else if proxyPass.contains(":8000") || proxyPass.contains(":5000") {
                    detectedBackendType = "Python/Flask"
                } else if proxyPass.contains(":1337") {
                    detectedBackendType = "Strapi"
                } else if proxyPass.contains(":5688") {
                    detectedBackendType = "Monitoring Service"
                }
            }
            
            endpoints.append(ServiceEndpoint(
                path: location.path,
                method: method,
                description: location.proxyPass != nil ? "Proxied to \(location.proxyPass!)" : nil
            ))
        }
        
        // Determine service type from proxy_pass destinations, not server_name
        let serviceType: ServiceInfo.ServiceType
        let category: ServiceInfo.ServiceCategory
        
        // Priority: Check proxy_pass destinations first (most accurate)
        if let backendType = detectedBackendType {
            if backendType.contains("Next.js") || backendType.contains("Monitoring") {
                serviceType = .nextjs
                category = .frontend
            } else if backendType.contains("Python") || backendType.contains("Flask") {
                serviceType = .flask
                category = .backend
            } else if backendType.contains("Strapi") {
                serviceType = .strapi
                category = .cms
            } else {
                serviceType = .nginx
                category = .infrastructure
            }
        } else {
            // Fallback: Check if this is just NGINX (no proxying)
            // Default: NGINX reverse proxy or redirect server
            serviceType = .nginx
            category = .infrastructure
        }
        
        // Create description based on what we discovered
        var description = "Discovered from NGINX config"
        if let backendType = detectedBackendType {
            description = "NGINX reverse proxy → \(backendType)"
        } else if server.port == 80 && server.locations.isEmpty {
            description = "HTTP to HTTPS redirect"
        }
        
        return ServiceInfo(
            name: serviceName,
            type: serviceType,
            port: server.port,
            baseURL: URL(string: baseURLString),
            category: category,
            description: description,
            icon: serviceType == .nginx ? "network" : "server.rack",
            tags: ["production", "discovered"],
            endpoints: endpoints
        )
    }
}
