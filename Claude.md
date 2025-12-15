# Claude Development Guide

This document provides comprehensive information for Claude (or any AI assistant) working on the Observability Swift Client project.

## Project Overview

The **Observability Swift Client** is a comprehensive, cross-platform observability client for Apple platforms that provides real-time monitoring, metrics collection, and distributed tracing capabilities for modern applications.

### Core Mission
To create a production-ready, high-performance observability SDK that helps developers monitor, debug, and optimize their iOS and macOS applications with minimal overhead and maximum insight.

### Platform Support
- **iOS**: 18.6+ (iPhone and iPad)
- **macOS**: 15.6+ (Universal Mac app)

## Architecture and Design

### Project Structure
```
observability-swift-client/
├── Observability/                 # Main app target
│   ├── ObservabilityApp.swift     # App entry point
│   ├── ContentView.swift          # Main UI view
│   ├── Item.swift                 # Data model
│   ├── Info.plist                 # App configuration
│   └── Assets.xcassets/          # App icons and assets
├── ObservabilityTests/           # Unit tests
├── ObservabilityUITests/         # UI tests
├── project.yml                   # XcodeGen project specification
├── Makefile                      # Build automation
├── .gitignore                    # Git ignore rules
├── Changelog.md                  # Version history
├── Roadmap.md                    # Development roadmap
├── Features.md                   # Feature documentation
├── Claude.md                     # This file
└── Agents.md                     # Agent specifications
```

### Build System
- **XcodeGen**: Project generation from `project.yml`
- **Make**: Build automation and development workflow
- **Swift Package Manager**: Dependency management

### Key Architectural Principles
1. **Performance First**: < 1% overhead in production
2. **Multi-Platform**: Shared core, platform-specific UI
3. **Security**: Sandbox-compliant with minimal permissions
4. **Extensibility**: Plugin architecture for custom components
5. **Observability**: Dogfooding - we monitor our monitoring tool

## Development Workflow

### Quick Start Commands
```bash
# Install dependencies (first time only)
make install

# Generate Xcode project
make generate

# Open in Xcode
make open

# Run tests
make test

# Clean build artifacts
make clean

# Build for all platforms
make build-all
```

### Common Development Tasks

#### Project Generation
```bash
# Generate project from YAML specification
make generate

# Force regeneration (clean first)
make generate-force
```

#### Building and Testing
```bash
# Debug build
make build

# Test on iOS simulator
make test

# Run unit tests only
make test-unit

# Run UI tests only
make test-ui

# Build for all platforms
make build-all
```

#### Code Quality
```bash
# Format Swift code (requires swiftformat)
make format

# Lint Swift code (requires swiftlint)
make lint
```

## Configuration Management

### Environment Variables
- `CONFIGURATION`: Debug/Release (default: Debug)
- `PLATFORM`: iOS/macOS (default: iOS)
- `SIMULATOR_NAME`: iOS Simulator device name

### XcodeGen Configuration
- Project specification: `project.yml`
- Supports iOS and macOS platforms
- Automatic resource file management
- File system synchronization enabled

### Build Settings
- **Swift Version**: 5.0
- **iOS Deployment Target**: 18.6
- **macOS Deployment Target**: 15.6
- **Code Signing**: Automatic
- **Sandbox**: Enabled with minimal permissions

## Code Style and Standards

### Swift Conventions
- Use Swift 5.0+ features (async/await, actors, etc.)
- Follow API Design Guidelines
- Use meaningful variable and function names
- Prefer composition over inheritance
- Leverage SwiftUI for UI components

### File Organization
- Group related functionality in modules
- Use file system sync for resource management
- Keep test files co-located with source
- Maintain clean target dependencies

### Documentation
- Document public APIs with Swift Doc Comments
- Update README.md for user-facing changes
- Maintain Changelog.md for version history
- Keep Roadmap.md current with development plans

## Testing Strategy

### Unit Testing
- Test all business logic and data models
- Mock external dependencies
- Achieve > 90% code coverage
- Use property-based testing where appropriate

### UI Testing
- Test critical user flows
- Use accessibility identifiers
- Test on multiple device sizes
- Include performance tests

### Integration Testing
- Test backend integrations
- Verify cross-platform behavior
- Test offline/online scenarios
- Validate security permissions

## Security Considerations

### Sandbox Permissions
- **Network**: Outgoing connections enabled
- **File System**: Downloads folder (read-only)
- **Bluetooth**: Enabled for device communication
- **User Files**: Read-write access
- **No Access**: Camera, location, contacts, calendars

### Data Protection
- Encrypt sensitive data in transit
- Minimize personal data collection
- Implement secure key storage
- Follow App Store guidelines

## Performance Requirements

### Metrics Collection
- **Overhead**: < 1% CPU usage impact
- **Memory**: < 10MB additional footprint
- **Latency**: < 1ms collection latency
- **Throughput**: > 10,000 metrics/second

### UI Performance
- 60fps scrolling and animations
- < 100ms app launch time
- < 50ms view transition times
- Responsive touch handling

## Platform-Specific Guidelines

### iOS Development
- Support iPhone and iPad layouts
- Adapt to Dynamic Type and Dark Mode
- Handle background/foreground transitions
- Optimize for battery life

### macOS Development
- Support window resizing and fullscreen
- Integrate with macOS menu bar
- Handle app lifecycle events
- Support keyboard shortcuts and navigation

## Troubleshooting Common Issues

### Build Failures
1. Check XcodeGen version: `make check-xcodegen`
2. Clean and regenerate: `make clean && make generate-force`
3. Verify Xcode command line tools installation
4. Check deployment target compatibility

### Runtime Issues
1. Verify sandbox entitlements
2. Check network permissions
3. Monitor memory usage with Instruments
4. Review console logs for errors

### Performance Problems
1. Profile with Instruments Time Profiler
2. Check for memory leaks
3. Optimize image and asset sizes
4. Review Swift concurrency usage

## Agent Integration

### When Working with Other Agents
- Coordinate with backend agents for API design
- Consult frontend agents for UI/UX consistency
- Work with testing agents for comprehensive coverage
- Collaborate with documentation agents for accuracy

### Agent-Specific Instructions
- **Backend Architects**: Provide API contracts and data models
- **Frontend Developers**: Implement SwiftUI views with accessibility
- **Test Engineers**: Create comprehensive test suites
- **DevOps Engineers**: Configure CI/CD pipelines and monitoring

## Release Management

### Versioning
- Follow Semantic Versioning (MAJOR.MINOR.PATCH)
- Update version numbers in `project.yml`
- Tag releases in git
- Update Changelog.md

### Release Checklist
- [ ] All tests passing
- [ ] Documentation updated
- [ ] Performance benchmarks met
- [ ] Security review completed
- [ ] App Store guidelines verified

## External Resources

### Documentation
- [Swift.org](https://swift.org/) - Language documentation
- [SwiftUI Documentation](https://developer.apple.com/xcode/swiftui/) - UI framework
- [XcodeGen Documentation](https://github.com/yonaskolb/XcodeGen) - Build system

### Tools
- **SwiftFormat**: Code formatting
- **SwiftLint**: Code linting
- **Instruments**: Performance profiling
- **Xcode**: IDE and debugger

### Communities
- **Swift Forums**: https://forums.swift.org/
- **Apple Developer Forums**: https://developer.apple.com/forums/
- **Stack Overflow**: swift and ios tags

## Contributing Guidelines

### Pull Request Process
1. Fork the repository
2. Create feature branch from main
3. Implement changes with tests
4. Update documentation
5. Submit pull request with description

### Code Review Checklist
- Code follows style guidelines
- Tests are comprehensive
- Documentation is updated
- Performance impact is measured
- Security implications are considered

---

This document should be updated as the project evolves. For the most current information, always refer to the source code and recent commits.