# CHANGELOG

## 1.9.0

### April 22, 2026

- **[Feature]** Added `consent` API to manage user consent for data collection.
- **[Enhancement]** Restored compatibility with Android Gradle Plugin 9.

## 1.8.0

### March 31, 2026

- **[Feature]** Added custom font support for accurate text rendering in session playback.
- **[Feature]** Capture accessibility labels for tapped elements.
- **[Enhancement]** Improved image processing speed and efficiency.

## 1.7.1

### January 21, 2026

- **[BugFix]** Fixed a bug in iOS capturing.
- **[Enhancement]** Improved iOS user info accuracy.

## 1.7.0

### January 5, 2026

- **[Enhancement]** Upgraded Protobuf dependency to `6.0.0`.
- **[Enhancement]** Improve invalid project ID detection before attempting to start.
- **[Enhancement]** Updated supported platforms to be more accurate.
- **[BugFix]** Fixed an issue so the end of a session is now always captured correctly.
- **[BugFix]** Fixed a rendering error that could occur when capturing certain text layouts.

## 1.6.0

### November 9, 2025

- **[Feature]** Add support for capturing most gradients applied to widgets.

## 1.5.0

### November 2, 2025

- **[Feature]** Add support for Dynamic configurations to allow runtime changes to Clarity settings without requiring app updates.
- **[Enhancement]** Improve hit testing accuracy for certain complex widget hierarchies.

## 1.4.3

### October 13, 2025

- **[BugFix]** Fix an issue where heatmaps were not working correctly when using setScreenName API.

## 1.4.2

### September 22, 2025

- **[Feature]** Support latest versions of dependencies

## 1.4.1

### September 18, 2025

- **[BugFix]** Fix a rare issue where uploading sessions would sometimes stop occuring

## 1.4.0

### September 3, 2025

- **[Feature]** Added `initialize` API to manually initialize Clarity with more control over initialization timing.
- **[Enhancement]** Network optimizations for improved data upload performance.

## 1.3.2

### August 20, 2025

- **[BugFix]** Fix an issue where VisibilityDetector's onVisibilityChanged is called more while using Clarity.

## 1.3.0

### August 10, 2025

- **[Feature]** Capture keyboard interactions.
- **[Feature]** Capture tap text.
- **[BugFix]** Fix an issue where selectable text was getting masked when it shouldn't.

## 1.2.0

### July 16, 2025

- **[Feature]** Added `pause` API to pause the Clarity session capturing.
- **[Feature]** Added `resume` API to resume the Clarity session capturing.
- **[Feature]** Added `isPaused` API to check if the Clarity session is currently paused.
- **[BugFix]** Stop capturing the current session when the Clarity Widget is removed from the widget tree.

## 1.1.0

### July 09, 2025

- **[Feature]** Added `setCustomUserId` API to set a custom user id for session tracking.
- **[Feature]** Added `setCustomTag` API to add custom tags to sessions.
- **[Feature]** Added `setCustomSessionId` API to set a custom session id for tracking specific sessions.
- **[Feature]** Added `setOnSessionStartedCallback` API that gets the clarity session id as a parameter to allow developers to execute custom logic when a session starts.
- **[Feature]** Added `getCurrentSessionUrl` API to retrieve the current Clarity session URL.
- **[Feature]** Added `sendCustomEvent` API to send custom events for the session to use in Smart events and Funnels.
- **[Feature]** Added `setCurrentScreenName` API to set the current screen name for the current page.

## 1.0.0

### June 16, 2025

- **Initial Release**: This is the first public release of the Flutter SDK.
