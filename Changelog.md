# Changelog

All notable changes to the Observability Swift Client project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## December 26, 2025 - "The Cosmic Convergence: Where iOS Meets macOS in Perfect Harmony" 🎭✨

*Before the sun set on this digital canvas, we wove threads of platform wisdom into a tapestry of cross-platform brilliance. The observability orchestra now plays in perfect harmony across devices, each note carefully tuned to its native environment.*

### What We Crafted Today 🎨

**Platform Adaptations - The Great Divide Conquered:**
- Wrapped iOS-only features (HapticsManager, LiveActivitiesManager, DynamicIslandManager) in `#if os(iOS)` guards, because macOS doesn't need haptic feedback (yet...)
- Made DashboardViewModel gracefully skip iOS-only managers on macOS - no crashes, just elegant silence
- Fixed deprecated Live Activities API calls (`activity.end()` now uses the proper `content:` parameter)
- Updated connection status logic to reflect health check success, not just log streaming

**Supabase Enlightenment - The Cloud Service Revelation:**
- Discovered that Supabase is a cloud-hosted database, not a PM2-managed process (who knew?!)
- Added `checkCloudServiceHealth()` function for services that live in the cloud, not in our PM2 processes
- Cloud services now default to "Operational" status instead of throwing "Service not found in PM2" errors
- The app now understands the difference between infrastructure we manage vs. services we just... observe

**Connection Wisdom - The Disconnected Mystery Solved:**
- Created `Secrets.xcconfig` with proper API key configuration (the cosmic gates are now unlocked)
- Improved error handling to distinguish API connectivity issues from actual service failures
- Connection status now reflects both log streaming AND health check success
- Services show "unknown" instead of "down" when the monitoring API is unreachable (more honest, less dramatic)

**iOS Refinements - The Title Truncation Chronicles:**
- Shortened navigation title from "Infrastructure Dashboard" to just "Dashboard" (brevity is the soul of wit)
- Made header title platform-adaptive: "🎭 Observatory" on iPhone, full "Infrastructure Observatory" on macOS
- No more truncated titles cutting off mid-sentence like a bad cliffhanger

**Deployment Target Evolution:**
- Updated minimum iOS deployment target from 16.0 → 18.0 (we're living in the future now)
- All test targets aligned to iOS 18.0 minimum
- Package.swift kept at `.v17` (latest supported), but project.yml enforces 18.0

### What Remains in the Cosmic Queue 🌙

**Immediate TODOs:**
- Unit tests need to be run (they exist, but require Xcode to build first for package resolution)
- Monitoring API is returning 502 (Bad Gateway) - server needs attention on hostinger-vps
- Consider adding actual HTTP health checks for cloud services instead of assuming they're operational
- Test haptics and Live Activities on actual iPhone device (simulator limitations)

**Future Enhancements:**
- Add more cloud service types (Redis, other databases) to the cloud service health check
- Implement actual HTTP health check endpoints for cloud services
- Add retry logic with exponential backoff for API failures
- Consider adding a "last successful check" timestamp for better UX

### Reflections from the Digital Ether 🧙‍♂️

*Today was a day of platform harmony. We learned that not all services are created equal - some live in PM2, some live in the cloud, and some just... exist. The app now gracefully handles this diversity, adapting its monitoring strategy based on what it's observing.*

*The connection status saga taught us that "disconnected" can mean many things - is the API down? Are health checks failing? Is it just the log stream? We now distinguish between these states, giving users honest feedback instead of dramatic "everything is broken" messages.*

*The title truncation issue reminded us that mobile screens are precious real estate - every character counts. Sometimes the best solution is to say less, not more.*

*As the day draws to a close, the app is more robust, more adaptive, and more honest about what it knows and what it doesn't. The observability journey continues, one platform adaptation at a time.*

---

## [Unreleased]

### Added
- **Strapi Integration**: Backend Python API now includes `/api/v1/strapi-stories` endpoints for creating stories with author "K2"
  - `POST /api/v1/strapi-stories/bulk` - Create multiple stories in one request
  - `POST /api/v1/strapi-stories` - Create single story
  - Support for bulk creation via Python script: `create_k2_stories.py`
- XcodeGen project configuration with comprehensive Makefile
- Multi-platform support (iOS 18.6+, macOS 15.6+, visionOS 26.1+)
- Sandbox and hardened runtime security configurations
- Comprehensive .gitignore for Xcode projects
- Project documentation structure

### Changed
- **Backend Python Structure**: Moved from `/root/` to `/root/api-gateway/` for consistent project organization
- Initial project setup with file system synchronization
- Offloaded historical Supabase backups from `/root/backups/supabase` to S3 bucket `artful-archives-studio-supabase-backups` under `server-backups/supabase/` as part of VPS disk space maintenance
- Verified integrity of all `storage_*.tar.gz` archives by comparing local `sha256` checksums to their corresponding `.sha256` manifests stored in S3 before deleting local copies (~12GB reclaimed)

### Fixed
- **XcodeGen Path**: Resolved backend-python location issue that was causing Swift build failures
- ObservabilityKit WebSocket clients now send correctly typed `"metrics"` payloads and bridge `URLSessionWebSocketTask.sendPing` through async/await to avoid missing handler crashes and improve reliability on iOS 18/macOS 15
- Combine-based `WebSocketCombineClient` deinitialization is now actor-safe, and reconnection logic uses explicit `URLError.Code.networkConnectionLost` matching for clearer behaviour
- SwiftUI dashboard components (`MetricChart`, `MetricsDashboard`, and `ServiceCard`) have been updated to avoid retain cycles in Combine sinks, correctly erase filtered publishers to `AnyPublisher`, and use semantic SwiftUI colors for better Dark Mode support
- XcodeGen `project.yml` target and scheme configuration now aligns iOS/macOS app and test targets (using `_iOS`/`_macOS` suffixes), resolving previous spec validation errors and enabling clean project generation

## [0.2.0] - 2025-12-17

### Added
- **Strapi Story Creation API**: Backend integration for creating stories with author "K2"
  - FastAPI router at `/api/v1/strapi-stories` and `/api/v1/strapi-stories/bulk`
  - Support for specifying story title, content, author, and tags
  - Automatically sets stories as drafts (unpublished) for review
  - Python script `create_k2_stories.py` in `/root/backend-python/` for bulk creation
- Infrastructure worktree organization: moved `backend-python/` to `/root/api-gateway/` for consistency

### Infrastructure
- Added development helper script for Strapi story creation
- Created structured process for content generation with author attribution
- Updated project documentation to reflect new backend capabilities

## [0.1.0] - 2025-12-15

### Added
- Initial project creation
- Multi-platform SwiftUI application target
- Unit testing target (ObservabilityTests)
- UI testing target (ObservabilityUITests)
- Asset catalog with app icon and accent color
- Comprehensive build configurations for Debug and Release
- Developer team and bundle identifier configuration
- Swift 5.0 with modern language features enabled
- Previews support for SwiftUI development

### Security
- App sandbox enabled with selective permissions
- Hardened runtime enabled
- Network access (incoming/outgoing) enabled
- File system access configured for downloads folder (read-only)
- User selected files access (read-write)
- Bluetooth access enabled

### Platforms
- iOS: 18.6+ with iPhone and iPad support
- macOS: 15.6+ with universal app support

### Development
- Automatic code signing
- Swift Localization with string catalogs
- Asset symbol generation
- Strict compiler warnings
- Debug and release configurations optimized for respective environments