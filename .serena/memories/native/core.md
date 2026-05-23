# Native Core

- This package is a Flutter plugin with Dart facade code plus Android/Kotlin and iOS/Swift host implementations.
- Pigeon source is `pigeons/messages.dart`; generated outputs are:
  - Dart: `lib/src/native/generated/messages.g.dart`
  - Kotlin: `android/src/main/kotlin/com/microsoft/clarity/generated/Messages.g.kt`
  - Swift: `ios/clarity_flutter/Sources/clarity_flutter/generated/Messages.g.swift`
- Pigeon APIs cover device info, package info, cache directory, user agent, connectivity status/events, and GAID. Most device/GAID calls are configured for serial background task queues.
- Dart native facade lives in `lib/src/native/clarity_platform.dart` and delegates to channel wrappers in `device_channel.dart`, `network_channel.dart`, and `gaid_channel.dart`.
- Android host implementations live under `android/src/main/kotlin/com/microsoft/clarity/api`; bridge helpers live under `android/src/main/kotlin/com/microsoft/clarity/bridges`; plugin entry is `ClarityFlutterPlugin.kt`.
- iOS host implementations live under `ios/clarity_flutter/Sources/clarity_flutter/api`; bridge helpers live under `ios/clarity_flutter/Sources/clarity_flutter/bridges`; plugin entry is `ClarityFlutterPlugin.swift`.
- Android build supports Kotlin plugin fallback behavior for AGP 9+ and sets JVM target 17.
- iOS Swift package targets iOS 12.0 and includes `PrivacyInfo.xcprivacy` as a processed resource.
