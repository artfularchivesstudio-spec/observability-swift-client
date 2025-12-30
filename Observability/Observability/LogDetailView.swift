//
//  LogDetailView.swift
//  Observability
//
//  🔍 The Cosmic Log Inspector - Where Server Messages Reveal Their Full Story ✨
//
//  "Every log entry is a chapter in the server's story. This view unfolds
//  the complete narrative, revealing all the details hidden in those cryptic lines."
//
//  - The Spellbinding Museum Director of Log Analysis

import SwiftUI
import ObservabilityCore
#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// 🔍 Comprehensive log entry detail view showing all available information
@available(macOS 14, iOS 17, *)
struct LogDetailView: View {
    let logEntry: ServerLogEntry
    @Environment(\.dismiss) private var dismiss
    @State private var copiedField: String?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header Section
                headerSection
                
                // Message Section (Full, untruncated)
                messageSection
                
                // Request Details (if available)
                if logEntry.requestMethod != nil || logEntry.requestPath != nil {
                    requestSection
                }
                
                // Network Information
                if logEntry.clientIP != nil || logEntry.userAgent != nil {
                    networkSection
                }
                
                // Metadata Section
                metadataSection
                
                // Raw Log Line
                rawLogSection
            }
            .padding()
        }
        .navigationTitle("Log Entry Details")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: toolbarPlacement) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        #if os(macOS)
        .onExitCommand {
            dismiss()
        }
        #endif
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                // Log Level Icon
                Image(systemName: levelIcon)
                    .font(.system(size: 32))
                    .foregroundColor(levelColor)
                    .frame(width: 48, height: 48)
                    .background(
                        Circle()
                            .fill(levelColor.opacity(0.1))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(logEntry.level.displayName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(levelColor)
                        
                        if logEntry.is500Error {
                            Text("500")
                                .font(.caption.monospaced())
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color.red)
                                .cornerRadius(4)
                        }
                    }
                    
                    Text(logEntry.source.capitalized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Timestamp
            HStack(spacing: 8) {
                Image(systemName: "clock")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(logEntry.timestamp.formatted(date: .complete, time: .complete))
                    .font(.subheadline.monospaced())
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.secondary.opacity(0.05))
        )
    }
    
    // MARK: - Message Section
    private var messageSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Message")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(logEntry.message)
                .font(.body.monospaced())
                .foregroundColor(.primary)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.secondary.opacity(0.05))
                )
        }
    }
    
    // MARK: - Request Section
    private var requestSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Request Details")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                if let method = logEntry.requestMethod {
                    CopyableInfoRow(
                        label: "Method",
                        value: method,
                        copiedField: $copiedField
                    )
                }
                
                if let path = logEntry.requestPath {
                    CopyableInfoRow(
                        label: "Path",
                        value: path,
                        copiedField: $copiedField
                    )
                }
                
                if let statusCode = logEntry.statusCode {
                    HStack {
                        Text("Status Code")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(statusCode)")
                            .font(.subheadline.monospaced())
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(statusCodeColor(statusCode))
                            .cornerRadius(4)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.secondary.opacity(0.05))
            )
        }
    }
    
    // MARK: - Network Section
    private var networkSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Network Information")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                if let clientIP = logEntry.clientIP {
                    CopyableInfoRow(
                        label: "Client IP",
                        value: clientIP,
                        copiedField: $copiedField
                    )
                }
                
                if let userAgent = logEntry.userAgent {
                    CopyableInfoRow(
                        label: "User Agent",
                        value: userAgent,
                        copiedField: $copiedField
                    )
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.secondary.opacity(0.05))
            )
        }
    }
    
    // MARK: - Metadata Section
    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Metadata")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                InfoRow(label: "Source", value: logEntry.source, icon: "server.rack")
                InfoRow(label: "Level", value: logEntry.level.displayName, icon: levelIcon)
                InfoRow(label: "Is Error", value: logEntry.isError ? "Yes" : "No", icon: logEntry.isError ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                InfoRow(label: "Is 500 Error", value: logEntry.is500Error ? "Yes" : "No", icon: logEntry.is500Error ? "xmark.octagon.fill" : "checkmark.circle.fill")
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.secondary.opacity(0.05))
            )
        }
    }
    
    // MARK: - Raw Log Section
    private var rawLogSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Raw Log Line")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {
                    copyToClipboard(logEntry.rawLine)
                    copiedField = "raw"
                }) {
                    HStack(spacing: 4) {
                        if copiedField == "raw" {
                            Image(systemName: "checkmark")
                                .foregroundColor(.green)
                        } else {
                            Image(systemName: "doc.on.doc")
                                .foregroundColor(.blue)
                        }
                        Text(copiedField == "raw" ? "Copied!" : "Copy")
                            .font(.caption)
                    }
                }
                .buttonStyle(.plain)
            }
            
            ScrollView(.horizontal, showsIndicators: true) {
                Text(logEntry.rawLine)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.primary)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.secondary.opacity(0.05))
            )
        }
    }
    
    // MARK: - Computed Properties
    private var levelColor: Color {
        switch logEntry.level {
        case .debug:
            return .gray
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
    
    private var levelIcon: String {
        switch logEntry.level {
        case .debug:
            return "magnifyingglass"
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
    
    private func statusCodeColor(_ code: Int) -> Color {
        switch code {
        case 200...299:
            return .green
        case 300...399:
            return .blue
        case 400...499:
            return .orange
        case 500...599:
            return .red
        default:
            return .gray
        }
    }
    
    private var toolbarPlacement: ToolbarItemPlacement {
        #if os(macOS)
        return .cancellationAction
        #else
        return .navigationBarTrailing
        #endif
    }
    
    private func copyToClipboard(_ text: String) {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #else
        UIPasteboard.general.string = text
        #endif
    }
}

/// 📋 Copyable info row component
@available(macOS 14, iOS 17, *)
struct CopyableInfoRow: View {
    let label: String
    let value: String
    @Binding var copiedField: String?
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline.monospaced())
                .foregroundColor(.primary)
                .textSelection(.enabled)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            
            Button(action: {
                copyToClipboard(value)
                copiedField = label
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    if copiedField == label {
                        copiedField = nil
                    }
                }
            }) {
                Image(systemName: copiedField == label ? "checkmark" : "doc.on.doc")
                    .font(.caption)
                    .foregroundColor(copiedField == label ? .green : .blue)
            }
            .buttonStyle(.plain)
            .help("Copy \(label)")
        }
    }
    
    private func copyToClipboard(_ text: String) {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #else
        UIPasteboard.general.string = text
        #endif
    }
}
