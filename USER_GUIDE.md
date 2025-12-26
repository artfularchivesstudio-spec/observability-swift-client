# 📱 Observability Swift Client - User Guide

## Welcome! 👋

Welcome to the Observability Swift Client - your comprehensive infrastructure monitoring companion for Apple devices.

## Getting Started

### First Launch

1. **Open the App**: Launch Observability from your home screen
2. **Grant Permissions**: Allow notifications when prompted (recommended for critical alerts)
3. **View Dashboard**: Your infrastructure services will appear automatically

### Understanding the Dashboard

#### Header Statistics
- **Services**: Total number of monitored services
- **Healthy**: Number of services operating normally
- **Issues**: Number of services with problems
- **Alerts**: Active alerts requiring attention

#### Service Cards
Each service card shows:
- Service name and type
- Current health status (color-coded indicator)
- Response time
- Last check timestamp

**Tap a service card** to see detailed information, metrics, and logs.

#### Recent Alerts
Critical alerts appear at the bottom:
- **Red dot**: Unacknowledged alert
- **Severity icons**: Error (❌), Warning (⚠️), Critical (🚨)
- **Tap an alert** to see full details and take action

## Features

### 🔔 Push Notifications

Receive instant notifications for:
- **Critical Alerts**: Service outages and critical errors
- **Error Alerts**: Service errors requiring attention
- **Warning Alerts**: Performance degradation warnings
- **Status Changes**: Services going up or down

**Notification Actions:**
- **Acknowledge**: Mark alert as acknowledged
- **View Details**: Open alert details in app

### 📊 Live Activities

See real-time service metrics in:
- **Dynamic Island** (iPhone 14 Pro+): Critical service outages
- **Lock Screen**: Service status updates
- **Notification Center**: Ongoing monitoring

Live Activities automatically update every 60 seconds and dismiss when services recover.

### 📱 Home Screen Widgets

Add widgets to your home screen for quick status checks:

1. **Long press** on home screen
2. **Tap +** button
3. **Search** for "Observability"
4. **Choose** widget size (Small, Medium, Large)
5. **Add** to home screen

**Widget Sizes:**
- **Small**: Single service status
- **Medium**: Multiple services overview
- **Large**: Full dashboard with metrics

### 📳 Haptic Feedback

Feel alerts through your device:
- **Critical Alerts**: Strong vibration
- **Service Down**: Error pattern vibration
- **Service Recovered**: Success vibration
- **Taps**: Light feedback for interactions

## Using the App

### Viewing Service Details

1. **Tap** any service card
2. **View** comprehensive information:
   - Current status and metrics
   - Performance insights
   - Recent logs
   - Performance trends

### Managing Alerts

1. **Tap** an alert in the Recent Alerts section
2. **Review** alert details:
   - Full message and context
   - Source information
   - Timeline of events
   - Metadata and tags
3. **Take Action**:
   - **Acknowledge**: Mark as seen
   - **Resolve**: Mark as fixed
   - **Reopen**: If issue persists

### Filtering Services

Use the status filter buttons to view:
- **All**: All services
- **Operational**: Healthy services only
- **Degraded**: Services with performance issues
- **Down**: Services that are offline
- **Maintenance**: Services in maintenance mode

## Tips & Tricks

### 🔍 Quick Actions

- **Swipe down** to refresh service status
- **Long press** service card for quick actions menu
- **Pull to refresh** to force update

### 📊 Understanding Metrics

- **CPU Usage**: Percentage of CPU resources used
- **Memory Usage**: RAM consumption in MB
- **Response Time**: Time to respond to health checks
- **Restarts**: Number of automatic restarts

### ⚠️ Alert Severity Levels

- **Info** (ℹ️): Informational messages
- **Warning** (⚠️): Performance issues, not critical
- **Error** (❌): Service errors requiring attention
- **Critical** (🚨): Service outages, immediate action needed

### 🎯 Best Practices

1. **Enable Notifications**: Don't miss critical alerts
2. **Check Regularly**: Review dashboard daily
3. **Acknowledge Alerts**: Keep alert list clean
4. **Use Widgets**: Quick status checks without opening app
5. **Review Insights**: Check recommendations for optimization

## Troubleshooting

### Notifications Not Working

1. Check Settings > Notifications > Observability
2. Ensure "Allow Notifications" is enabled
3. Check "Critical Alerts" is enabled
4. Verify Do Not Disturb is not blocking

### Services Not Updating

1. Check internet connection
2. Verify API key is correct
3. Pull to refresh manually
4. Restart the app

### Widget Not Showing Data

1. Remove and re-add widget
2. Ensure app has been opened recently
3. Check widget refresh settings
4. Verify app has necessary permissions

### Live Activities Not Appearing

1. Ensure Live Activities are enabled in Settings
2. Check that service has critical issues
3. Verify iOS 16.1+ is installed
4. Restart device if needed

## Privacy & Security

- **No Personal Data**: We don't collect personal information
- **Secure Connections**: All data encrypted in transit
- **Local Storage**: Metrics cached locally for performance
- **API Key Security**: Stored securely in device keychain

## Support

### Getting Help

- **Documentation**: See `DOCUMENTATION.md`
- **API Reference**: See `API_DOCUMENTATION.md`
- **Issues**: Report on GitHub

### Feedback

We love feedback! Share your thoughts and suggestions to help us improve.

---

*"Monitor with confidence, respond with speed"* ✨🎭

