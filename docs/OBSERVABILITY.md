# Observability and Performance Guide

## Overview

Comprehensive observability strategy covering logging, crash reporting, performance monitoring, and analytics to ensure a high-quality user experience.

## Logging Strategy

### Structured Logging
```swift
import os.log

// Unified logging system
enum LogCategory: String, CaseIterable {
    case gameEngine = "com.othello.game-engine"
    case ai = "com.othello.ai"
    case network = "com.othello.network"
    case ui = "com.othello.ui"
    case performance = "com.othello.performance"
    case security = "com.othello.security"
}

final class Logger {
    private let osLog: OSLog
    
    init(category: LogCategory) {
        self.osLog = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: category.rawValue)
    }
    
    func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        os_log("%{public}s:%d %{public}s - %{public}s", log: osLog, type: .info, 
               file, line, function, message)
    }
    
    func error(_ error: Error, file: String = #file, function: String = #function, line: Int = #line) {
        os_log("%{public}s:%d %{public}s - %{public}s", log: osLog, type: .error,
               file, line, function, error.localizedDescription)
    }
}
```

### Log Levels and Usage
- **Debug**: Development debugging only
- **Info**: General app flow and user actions
- **Warning**: Recoverable errors and unexpected conditions
- **Error**: Unrecoverable errors and crashes
- **Critical**: Security incidents and data corruption

## Crash Reporting

### Crash Analytics Integration
```swift
// Crash reporting service abstraction
protocol CrashReportingService {
    func recordCrash(_ error: Error, userInfo: [String: Any]?)
    func recordNonFatalError(_ error: Error, context: String)
    func setUserIdentifier(_ id: String)
    func setCustomKey(_ key: String, value: String)
}

// Implementation for chosen service (Crashlytics, Sentry, etc.)
final class CrashReporter: CrashReportingService {
    // Implementation details
}
```

### Custom Crash Context
```swift
// Game-specific crash context
struct GameCrashContext {
    let gameMode: GameMode
    let currentPlayer: Player
    let moveCount: Int
    let aiDifficulty: AIDifficulty?
    let boardState: String // Serialized board for debugging
    
    var userInfo: [String: Any] {
        return [
            "game_mode": gameMode.rawValue,
            "current_player": currentPlayer.rawValue,
            "move_count": moveCount,
            "ai_difficulty": aiDifficulty?.rawValue ?? "none",
            "board_state": boardState
        ]
    }
}
```

## Performance Monitoring

### App Launch Performance
```swift
// Launch time tracking
final class LaunchPerformanceTracker {
    private let startTime: CFAbsoluteTime
    
    init() {
        self.startTime = CFAbsoluteTimeGetCurrent()
    }
    
    func recordLaunchComplete() {
        let launchTime = CFAbsoluteTimeGetCurrent() - startTime
        Analytics.shared.recordEvent("app_launch_time", parameters: [
            "duration_ms": Int(launchTime * 1000)
        ])
        
        if launchTime > 2.0 {
            Logger(category: .performance).warning("Slow app launch: \(launchTime)s")
        }
    }
}
```

### Game Performance Metrics
```swift
// Game-specific performance tracking
final class GamePerformanceTracker {
    func trackAIThinkTime(difficulty: AIDifficulty, duration: TimeInterval) {
        Analytics.shared.recordEvent("ai_think_time", parameters: [
            "difficulty": difficulty.rawValue,
            "duration_ms": Int(duration * 1000)
        ])
    }
    
    func trackFrameRate() {
        // Monitor UI responsiveness during gameplay
    }
    
    func trackMemoryUsage() {
        let memoryUsage = getCurrentMemoryUsage()
        if memoryUsage > memoryThreshold {
            Logger(category: .performance).warning("High memory usage: \(memoryUsage)MB")
        }
    }
}
```

### Time to Interactive (TTI)
```swift
// Track when app becomes fully interactive
struct InteractivityTracker {
    static func markInteractive() {
        let timeToInteractive = CFAbsoluteTimeGetCurrent() - AppDelegate.appStartTime
        Analytics.shared.recordEvent("time_to_interactive", parameters: [
            "duration_ms": Int(timeToInteractive * 1000)
        ])
    }
}
```

## Analytics Framework

### Event Tracking
```swift
// Privacy-first analytics
protocol AnalyticsService {
    func recordEvent(_ name: String, parameters: [String: Any]?)
    func setUserProperties(_ properties: [String: String])
    func incrementCounter(_ counterName: String, by value: Int)
}

// Game-specific analytics events
enum AnalyticsEvent {
    case gameStarted(mode: GameMode, aiDifficulty: AIDifficulty?)
    case gameCompleted(winner: Player?, moves: Int, duration: TimeInterval)
    case moveExecuted(player: Player, position: BoardPosition, capturedPieces: Int)
    case aiMoveCalculated(difficulty: AIDifficulty, thinkTime: TimeInterval)
    case settingsChanged(setting: String, newValue: String)
    case accessibilityFeatureUsed(feature: String)
    
    var name: String {
        switch self {
        case .gameStarted: return "game_started"
        case .gameCompleted: return "game_completed"
        case .moveExecuted: return "move_executed"
        case .aiMoveCalculated: return "ai_move_calculated"
        case .settingsChanged: return "settings_changed"
        case .accessibilityFeatureUsed: return "accessibility_feature_used"
        }
    }
    
    var parameters: [String: Any] {
        // Event-specific parameters
    }
}
```

### User Experience Metrics
```swift
// UX quality indicators
struct UXMetrics {
    static func trackUserEngagement() {
        // Session duration, games per session, return rate
    }
    
    static func trackGameCompletion(startTime: Date, endTime: Date, outcome: GameOutcome) {
        let duration = endTime.timeIntervalSince(startTime)
        Analytics.shared.recordEvent("game_session", parameters: [
            "duration_minutes": duration / 60,
            "outcome": outcome.rawValue,
            "completion_rate": 1.0
        ])
    }
    
    static func trackUserFrustration(ragequits: Int, invalidMoveAttempts: Int) {
        if ragequits > 0 || invalidMoveAttempts > 5 {
            Analytics.shared.recordEvent("user_frustration", parameters: [
                "ragequits": ragequits,
                "invalid_moves": invalidMoveAttempts
            ])
        }
    }
}
```

## Binary Size Optimization

### Size Monitoring
```swift
// Build phase script for size tracking
"""
#!/bin/bash
APP_SIZE=$(du -sh "$BUILT_PRODUCTS_DIR/$PRODUCT_NAME.app" | cut -f1)
echo "App bundle size: $APP_SIZE"

# Alert if size exceeds threshold
SIZE_BYTES=$(du -s "$BUILT_PRODUCTS_DIR/$PRODUCT_NAME.app" | cut -f1)
THRESHOLD=50000  # 50MB in KB

if [ $SIZE_BYTES -gt $THRESHOLD ]; then
    echo "WARNING: App size exceeds threshold"
    exit 1
fi
"""
```

### Optimization Strategies
- Asset compression and optimization
- On-demand resource loading
- Code splitting for features
- Dead code elimination
- Dependency audit and reduction

## Real-User Monitoring (RUM)

### Performance Vitals
```swift
// Core Web Vitals adapted for mobile
struct MobileVitals {
    static func trackAppResponsiveness() {
        // Track UI freezes, ANRs, slow transitions
    }
    
    static func trackMemoryPressure() {
        // Monitor memory warnings and app terminations
    }
    
    static func trackBatteryImpact() {
        // CPU usage, background processing time
    }
}
```

### Custom Metrics Dashboard
- Game completion rates by difficulty
- AI performance across device types
- Accessibility feature adoption
- Crash-free session rates
- User retention cohorts

## Privacy-Compliant Analytics

### Data Collection Principles
- Explicit user consent for analytics
- Anonymous identifiers only
- Local aggregation before transmission
- Opt-out mechanisms
- GDPR/CCPA compliance

### Implementation
```swift
// Privacy-first analytics wrapper
final class PrivacyCompliantAnalytics {
    private var userConsent: Bool = false
    private let localBuffer: [AnalyticsEvent] = []
    
    func requestAnalyticsConsent() async -> Bool {
        // Present consent dialog
        // Store preference securely
    }
    
    func recordEvent(_ event: AnalyticsEvent) {
        guard userConsent else {
            // Store locally or discard
            return
        }
        
        // Process and send event
    }
}
```

## Monitoring Alerts

### Performance Thresholds
- App launch time > 3 seconds
- AI calculation time > 5 seconds (hard difficulty)
- Memory usage > 150MB
- Crash rate > 0.1%
- Battery drain > industry benchmarks

### Business Metrics
- Daily/Monthly Active Users
- Game completion rate < 80%
- User retention < industry standards
- In-app purchase conversion (future)
- Support ticket volume increases

## Development and Production Environments

### Environment-Specific Configuration
```swift
enum Environment {
    case development
    case staging
    case production
    
    var analyticsConfig: AnalyticsConfig {
        switch self {
        case .development:
            return AnalyticsConfig(enabled: false, verbose: true)
        case .staging:
            return AnalyticsConfig(enabled: true, sampleRate: 1.0)
        case .production:
            return AnalyticsConfig(enabled: true, sampleRate: 0.1)
        }
    }
}
```

### A/B Testing Framework
```swift
// Feature flag system for experimentation
protocol ExperimentationService {
    func isFeatureEnabled(_ feature: String, for user: String) -> Bool
    func getExperimentVariant(_ experiment: String, for user: String) -> String?
    func recordExperimentExposure(_ experiment: String, variant: String)
}
```

## Incident Response

### Automated Alerting
- Crash rate spikes
- Performance regressions
- Security incidents
- Service degradations

### Response Procedures
1. Immediate assessment and triage
2. Impact analysis and communication
3. Hotfix deployment procedures
4. Post-incident review and learning
5. Prevention measure implementation