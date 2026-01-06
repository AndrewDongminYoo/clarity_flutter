# Official Clarity Flutter SDK (Forked by AndrewDongminYoo)

> ⚠️ Unofficial fork. Not affiliated with Microsoft.
> This repository exists to make `clarity_flutter` compatible with `protobuf ^6.0.0` (and common generators such as `retrofit_generator`) by restoring `.proto` sources and regenerating protobuf outputs.
> Licensed under MIT; original copyright © Microsoft Corp. is retained.

## Overview

The Clarity Flutter SDK allows you to integrate Clarity analytics into your Flutter applications. This SDK is the latest addition to Clarity’s range of SDKs available for Native Android, iOS, React native, Cordova and Ionic. Clarity SDKs help you capture user interactions, screen views, and other important metrics to gain insights into user behavior and improve your business KPIs.

The SDK supports Flutter on both Android and iOS devices.

## Contents

- [Overview](#overview)
- [Why This Fork Exists (protobuf 6 upgrade)](#why-this-fork-exists-protobuf-6-upgrade)
- [Project Structure](#project-structure)
- [Features](#features)
- [How Does Clarity Flutter SDK Work?](#how-does-clarity-flutter-sdk-work)
- [Getting Started](#getting-started)
- [Integration Steps](#integration-steps)
  - [Step 1: Add Dependency (Git)](#step-1-add-dependency-git)
  - [Step 2: Import the Package](#step-2-import-the-package)
  - [Step 3: Initialize Your App](#step-3-initialize-your-app)
- [Configuration Options](#configuration-options)
- [Masking Widgets](#masking-widgets)
  - [ClarityMask](#claritymask)
  - [ClarityUnmask](#clarityunmask)
- [API](#api)
  - [initialize](#initialize)
  - [setCustomUserId](#setcustomuserid)
  - [setCustomTag](#setcustomtag)
  - [setCustomTags](#setcustomtags)
  - [setCustomSessionId](#setcustomsessionid)
  - [setOnSessionStartedCallback](#setonsessionstartedcallback)
  - [getCurrentSessionUrl](#getcurrentsessionurl)
  - [sendCustomEvent](#sendcustomevent)
  - [setCurrentScreenName](#setcurrentscreenname)
  - [startNewSession](#startnewsession)
  - [pause](#pause)
  - [resume](#resume)
  - [isPaused](#ispaused)
- [Troubleshooting](#troubleshooting)
- [Known Limitations](#known-limitations)
- [Project Support](#project-support)

## Why This Fork Exists (protobuf 6 upgrade)

This repository is a **fork of the official `clarity_flutter` package**.

The upstream SDK ships protobuf-generated Dart files, but the **original `.proto` sources are not publicly available on GitHub**. As a result, when the ecosystem moved forward (e.g., `retrofit_generator` and other code generators depending on newer `protobuf`), some developers started hitting **dependency conflicts** between:

- `clarity_flutter` (historically tied to older `protobuf` constraints)
- other tooling / generators requiring `protobuf >= 6`

To unblock these projects, this fork reconstructs the missing `.proto` file(s) from the published package and regenerates Dart protobuf code using modern tooling.

### What was done

- Reconstructed ignored/missing `.proto` sources by decoding protobuf descriptors included in the published Dart artifacts (`*.pbjson.dart`).
- Restored the schema as `proto/MutationPayload.proto`.
- Regenerated Dart protobuf outputs with modern tooling and upgraded runtime dependency to `protobuf 6.0.0`.
- Verified that the regenerated code is wire-compatible with the published SDK (expected codegen differences may exist depending on `protoc_plugin` versions, but message layout and field numbers remain consistent).

### Why this may help you

If you're seeing dependency resolution failures such as conflicts between `retrofit_generator` (or other generators) and `clarity_flutter` due to protobuf version constraints, this fork is intended to be a drop-in alternative that plays nicely with the modern Dart/Flutter protobuf ecosystem.

> Note: This fork focuses on **dependency compatibility and reproducible code generation**, not on changing Clarity behavior.

## Project Structure

This repository is organized to keep the SDK runtime, generated protobuf models, and maintenance tooling clearly separated.

### Key directories

- `lib/clarity_flutter.dart`

  Public entrypoint for the package.

- `lib/src/`

  Core SDK implementation.
  - `core/`: shared primitives / core runtime logic
  - `helpers/`: snapshotting, gesture processing, telemetry tracking, view hierarchy processing, etc.
  - `managers/`, `observers/`, `registries/`, `repositories/`: internal modules that orchestrate capturing and uploading
  - `models/`: SDK domain models
    - `models/generated/`: **protobuf-generated models** (Dart outputs)
    - other folders: assets/capture/display/events/ingest/session/telemetry/text/view_hierarchy, etc.

- `proto/`

  Restored protobuf sources used for regeneration.
  - `proto/MutationPayload.proto`

- `scripts/`

  Maintenance utilities for schema reconstruction and regeneration support.
  - `scripts/reconstruct_proto_from_pbjson.py`: reconstructs `.proto` from `*.pbjson.dart` descriptors
  - `scripts/requirements.txt`: Python dependencies for scripts

- `example/`

  Example Flutter app for local testing.

### Tooling / repo meta

- `.github/`: CI workflows
- `.trunk/`: lint/format tooling
- `analysis_options.yaml`, `build.yaml`: analyzer / build configuration
- `Makefile`: convenience commands (e.g., regeneration workflows)

## Features

- ✅ Session Recordings
- ✅ Heatmaps
- ✅ User interaction insights such as Rage taps, Dead taps, Taps, and Double taps.

> **Note:** Smart Events, Funnels, and Components are not supported in the Clarity Flutter SDK at the moment.

## How Does Clarity Flutter SDK Work?

> **Note:** The Flutter SDK only captures and uploads sessions when the device is connected to the internet.

Once the SDK is successfully integrated into the mobile application and is initialized, data is automatically captured and sent to Clarity’s servers. The SDK captures:

- User screens / visuals
- User interactions (taps, double taps, and touch motions)

Captured data is periodically uploaded while the application is running, and the device is connected to the internet.

> **Tip!** You should see your current Live Session show up on the dashboard right away. The complete session data takes about 30 minutes up to 2 hours to show up on the dashboard.

## Getting Started

To get started with Clarity, sign up and create a project. Follow the instructions on the [Clarity SDK Getting Started](https://learn.microsoft.com/en-us/clarity/mobile-sdk/sdk-getting-started) page.

## Integration Steps

This fork is **not published to pub.dev**. Install it via a Git dependency.

### Step 1: Add Dependency (Git)

Add this to your app’s `pubspec.yaml`:

```yaml
dependencies:
  clarity_flutter:
    git:
      url: https://github.com/AndrewDongminYoo/clarity_flutter.git
      ref: v1.7.0-fork.1
```

> If you're migrating from the upstream pub.dev package, remove any `dependency_overrides` you previously added for `protobuf`, and let pub resolve dependencies normally.

### Step 2: Import the Package

Import the `clarity_flutter` package in your `main.dart` file:

```dart
import 'package:clarity_flutter/clarity_flutter.dart';
```

### Step 3: Initialize Your App

There are two ways to initialize Clarity in your Flutter app:

#### Option 1: Using `Clarity.initialize` (Recommended)

```dart
import 'package:flutter/material.dart';
import 'package:clarity_flutter/clarity_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    _initializeClarity();
  }

  void _initializeClarity() {
    final config = ClarityConfig(
      projectId: "your_project_id", // Find it in Clarity Dashboard settings.
    );

    Clarity.initialize(context, config);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clarity Flutter SDK Example'),
      ),
      body: Center(
        child: Text('Hello, Clarity!'),
      ),
    );
  }
}

```

> When using `Clarity.initialize`, call it with a valid `BuildContext` after the widget is built (typically in `initState`).

#### Option 2: Using `ClarityWidget`

```dart
import 'package:flutter/material.dart';
import 'package:clarity_flutter/clarity_flutter.dart';

void main() {
  final config = ClarityConfig(
    projectId: "your_project_id", // Find it in Clarity Dashboard settings.
  );

  runApp(
    ClarityWidget(
      app: MyApp(),
      clarityConfig: config,
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Clarity Flutter SDK Example'),
        ),
        body: Center(
          child: Text('Hello, Clarity!'),
        ),
      ),
    );
  }
}
```

> **Note:** When using `Clarity.initialize`, make sure to call it with a valid `BuildContext` after the widget is built, typically in the `initState` method of a StatefulWidget.

## Configuration Options

The `ClarityConfig` object has the following configuration options:

- `projectId` (String): The unique identifier for your Clarity project. You can find it on the Settings page of Clarity dashboard. This ID is essential for routing data to the correct Clarity project.
- `userId` [Deprecated: Please use [`Clarity.setCustomUserId(customUserId)`](#setcustomuserid) instead] (String, optional): The unique identifier for the user. Must be a base-36 string larger than 0, smaller than `1z141z4`, non-empty and without any uppercase letters. If not provided, a Clarity generated user ID will be used instead.
- `logLevel` (LogLevel, optional): The logging level for Clarity. **Defaults to `LogLevel.Info` if not provided (in debug builds).** Possible values are:
  - `LogLevel.Verbose`: Detailed debug information.
  - `LogLevel.Debug`: Debug information.
  - `LogLevel.Info`: Informational messages.
  - `LogLevel.Warn`: Warning messages.
  - `LogLevel.Error`: Error messages.
  - `LogLevel.None`: No logging.

> **Tip!** In non-debug (production) builds, `loglevel` is forced to `None` to eliminate any performance overhead.

Example:

```dart
final config = ClarityConfig(
  projectId: "your_project_id",
  logLevel: LogLevel.Info,
);
```

## Masking Widgets

The Clarity Flutter SDK provides masking widgets to mask sensitive information in your app. These widgets are `ClarityMask` and `ClarityUnmask`.

> **Note:** Clarity supports masking modes that are applied on the entire app. More on how to use them and what to expect in [the masking modes guide](https://learn.microsoft.com/en-us/clarity/mobile-sdk/clarity-sdk-masking#masking-modes).

### ClarityMask

Use `ClarityMask` to mask widgets containing sensitive information.

```dart
import 'package:flutter/material.dart';
import 'package:clarity_flutter/clarity_flutter.dart';

class MaskedWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClarityMask(
      child: Text('Sensitive Information'),
    );
  }
}
```

### ClarityUnmask

Use `ClarityUnmask` to unmask widgets within a masked area.

```dart
import 'package:flutter/material.dart';
import 'package:clarity_flutter/clarity_flutter.dart';

class UnmaskedWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClarityUnmask(
      child: Text('Non-sensitive Information'),
    );
  }
}
```

## API

The Clarity Flutter SDK provides some public APIs to allow interaction with the running Clarity session.

### initialize

```dart
bool Clarity.initialize(BuildContext context, ClarityConfig clarityConfig)
```

Initializes Clarity to start capturing the current session data.

`context` (BuildContext): The BuildContext of the widget tree.

`clarityConfig` (ClarityConfig): The configuration for the Clarity session.

Returns `true` if the initialization is possible; otherwise `false`.

- This function should only be called on the UI Isolate.
- Make sure to call it with a valid `BuildContext` after the widget is built, typically in the `initState` method of a StatefulWidget.

```dart
import 'package:clarity_flutter/clarity_flutter.dart';

void _initializeClarity() {
  final config = ClarityConfig(
    projectId: "your_project_id"
  );

  Clarity.initialize(context, config);
}
```

### setCustomUserId

```dart
bool Clarity.setCustomUserId(String customUserId)
```

Sets a custom user ID for the current session. This ID can be used to filter sessions on the Clarity dashboard.

`customUserId` (String): must be a nonempty string with a maximum of 255 characters and can't consist only of whitespace.

Returns `true` if the custom user ID was set successfully; otherwise `false`.

- This function should only be called on the UI Isolate.
- Unlike the `userId` provided in the `ClarityConfig`, the `customUserId` has fewer restrictions.
- We recommend NOT to set any Personally Identifiable Information values inside this field.

```dart
import 'package:clarity_flutter/clarity_flutter.dart';

void setClarityUserId() {
  Clarity.setCustomUserId('user_id');
}
```

### setCustomTag

```dart
bool Clarity.setCustomTag(String key, String value)
```

Sets a custom tag for the current session. This tag can be used to filter sessions on the Clarity dashboard.

`key` (String): must be a nonempty string with a maximum of 255 characters and can't consist only of whitespace.

`value` (String): must be a nonempty string with a maximum of 255 characters and can't consist only of whitespace.

Returns `true` if the tag was set successfully; otherwise `false`.

- This function should only be called on the UI Isolate.
- We recommend NOT to set any Personally Identifiable Information values inside this field.

```dart
import 'package:clarity_flutter/clarity_flutter.dart';

void setClarityCustomTag() {
  Clarity.setCustomTag('custom_tag_key', 'custom_tag_value');
}
```

### setCustomTags

```dart
bool Clarity.setCustomTags(String key, Iterable<String> values)
```

Sets a custom tag with multiple values for the current session. These tags can be used to filter sessions on the Clarity dashboard.

`key` (String): must be a nonempty string with a maximum of 255 characters and can't consist only of whitespace.

`values` (`Iterable<String>`): must contain at least one nonempty string value. Each value must have a maximum of 255 characters, can't consist only of whitespace, and duplicate entries are ignored.

Returns `true` if the tags were set successfully; otherwise `false`.

- This function should only be called on the UI Isolate.
- We recommend NOT to set any Personally Identifiable Information values inside this field.

```dart
import 'package:clarity_flutter/clarity_flutter.dart';

void setClarityCustomTags() {
  Clarity.setCustomTags('custom_tag_key', ['value_a', 'value_b']);
}
```

### setCustomSessionId

```dart
bool Clarity.setCustomSessionId(String customSessionId)
```

Sets a custom session ID for the current session. This ID can be used to filter sessions on the Clarity dashboard.

`customSessionId` (String): must be a nonempty string with a maximum of 255 characters and can't consist only of whitespace.

Returns `true` if the custom session ID was set successfully; otherwise `false`.

- This function should only be called on the UI Isolate.
- We recommend NOT to set any Personally Identifiable Information values inside this field.

```dart
import 'package:clarity_flutter/clarity_flutter.dart';

void setClarityCustomSessionId() {
  Clarity.setCustomSessionId('custom_session_id');
}
```

### setOnSessionStartedCallback

```dart
SessionStartedCallback = void Function(String sessionId)
bool Clarity.setOnSessionStartedCallback(SessionStartedCallback callback)
```

Sets a callback function that's invoked whenever a new Clarity session starts or an existing session is resumed on app startup.

callback (void Function(String sessionId)): The callback to be invoked whenever a Clarity session starts - the callback receives the new or resumed session ID as a string parameter.

Returns `true` if the callback was set successfully; otherwise `false`.

- If the callback is set after a session has already started, it will be invoked immediately.
- The specified callback is guaranteed to run on the main isolate.

```dart
import 'package:clarity_flutter/clarity_flutter.dart';

void setClarityOnSessionStartedCallback() {
  Clarity.setOnSessionStartedCallback((String sessionId) {
    // Handle the session ID here.
  });
}
```

### getCurrentSessionUrl

```dart
String? Clarity.getCurrentSessionUrl()
```

Gets the URL of the current Clarity session recording on the Clarity dashboard if a session has already started; otherwise `null`.

Returns a string representing the URL of the current Clarity session recording on the Clarity dashboard if a session has already started; otherwise `null`.

- Initially, this function might return `null` until a Clarity session begins.
- To ensure a valid session URL, use this method within the callbacks of [`setOnSessionStartedCallback`](#setonsessionstartedcallback).
- This function should only be called on the UI Isolate.

```dart
import 'package:clarity_flutter/clarity_flutter.dart';

void getClaritySessionUrl() {
  String? claritySessionUrl = Clarity.getCurrentSessionUrl();
}
```

### sendCustomEvent

```dart
bool Clarity.sendCustomEvent(String value)
```

Sends a custom event to the current Clarity session.
These custom events can be used to track specific user interactions or actions that Clarity's built-in event tracking doesn't automatically capture.

`value` (String): must be a nonempty string with a maximum of 254 characters and can't consist only of whitespace.

Returns `true` if the custom event was sent successfully; otherwise `false`.

- This API can be called multiple times per page to track various user actions.
- Each custom event is logged individually and can be filtered, viewed and analyzed in the Clarity dashboard.
- This function should only be called on the UI Isolate.
- We recommend NOT to set any Personally Identifiable Information values inside this field.

```dart
import 'package:clarity_flutter/clarity_flutter.dart';

void sendClarityCustomEvent() {
  Clarity.sendCustomEvent('custom_event');
}
```

### setCurrentScreenName

```dart
bool Clarity.setCurrentScreenName(String? screenName)
```

This function allows you to provide a custom screen name that replaces the default screen name.

`screenName` (String, optional): must be a nonempty string with a maximum of 255 characters and can't consist only of whitespace - Set to `null` to remove the custom screen name.

Returns `true` if the screen name was set successfully; otherwise `false`.

- Clarity starts a new page whenever the screen name changes.
- This function should only be called on the UI Isolate.
- To cover all route changes, it is recommended to call this function inside a RouteObserver.

```dart
import 'package:clarity_flutter/clarity_flutter.dart';

void setClarityScreenName() {
  Clarity.setCurrentScreenName('screen_name');
}
```

### startNewSession

```dart
SessionStartedCallback = void Function(String sessionId)
bool Clarity.startNewSession(SessionStartedCallback callback)
```

Starts a new Clarity session, ending the current session if one is active.

`callback` (void Function(String sessionId)): Invoked when the new session starts. Receives the newly created session ID.

Returns `true` if a new session was started successfully; otherwise `false`.

- This function should only be called on the UI Isolate.
- The specified callback is guaranteed to run on the main isolate.
- Use this when you want to segment recordings into separate sessions (for example, after a user signs out and a different user signs in).

```dart
import 'package:clarity_flutter/clarity_flutter.dart';

void restartClaritySession() {
  Clarity.startNewSession((String newSessionId) {
    // Handle the new session ID here.
  });
}
```

### pause

```dart
bool Clarity.pause()
```

Pauses the Clarity session capturing until a call to the [`resume`](#resume) function is made.

Returns `true` if the session was paused successfully; otherwise `false`.

- This function should only be called on the UI Isolate.
- Calling pause will stop the capture of events and data until [resume] is called.

```dart
import 'package:clarity_flutter/clarity_flutter.dart';

void pauseClarity() {
  Clarity.pause();
}
```

### resume

```dart
bool Clarity.resume()
```

Resumes the Clarity session capturing only if it was previously paused by a call to the [`pause`](#pause) function.

Returns `true` if the session was resumed successfully; otherwise `false`.

- This function should only be called on the UI Isolate.
- If the session is not paused, calling resume will have no effect.

```dart
import 'package:clarity_flutter/clarity_flutter.dart';

void resumeClarity() {
  Clarity.resume();
}
```

### isPaused

```dart
bool Clarity.isPaused()
```

Checks if the Clarity session is currently paused.

Returns `true` if the session is paused; otherwise `false`.

- This function should only be called on the UI Isolate.

```dart
import 'package:clarity_flutter/clarity_flutter.dart';

void isClarityPaused() {
  Clarity.isPaused();
}
```

## Troubleshooting

If you can't see any data on the dashboard, follow these steps:

1. Set the Clarity log level to `Verbose` to check for initialization errors.
2. Filter the logs on `[Clarity]` to view Clarity-specific logs, to make sure clarity is running correctly.
3. Ensure your device is connected to the internet.
4. Verify that your project ID is correct. You can find it on the Settings page of Clarity dashboard.

Example:

```dart
final config = ClarityConfig(
  projectId: "your_project_id",
  logLevel: LogLevel.Verbose,
);
```

## Known Limitations

> Fork note: Protobuf Dart output may differ slightly from older upstream outputs due to modern `protoc_plugin` behavior, but **wire format and field compatibility are preserved**.

- Offline session data upload is NOT supported at the moment; only session data captured while the user is online is sent.
- Native view capturing (including web views) is NOT supported at the moment; these views may appear as covered in recordings.
- Font support is limited at the moment; you might see font differences in recordings.

### Fork-specific notes

- This fork primarily focuses on **dependency compatibility** (notably `protobuf ^6.0.0`) and **reproducible protobuf regeneration**.
- If you hit build errors related to protobuf / generated code, open an issue in this repository with:
  - your `flutter --version`
  - your `flutter pub deps | grep protobuf`
  - and the full error log

## Project Support

### Support for this fork

This is an **unofficial, community-maintained fork**.

- For fork-specific issues (protobuf 6 compatibility, regenerated models, analyzer/lints, dependency constraints, build failures), please open a GitHub issue in this repository.
- Include a minimal reproduction and your dependency tree (`flutter pub deps` output) when possible.

### Upstream / Microsoft Clarity support

For questions about **Clarity product behavior** (dashboard, session replay features, project setup, account issues, etc.), refer to the official [Microsoft Clarity documentation](https://learn.microsoft.com/en-us/clarity/mobile-sdk/sdk-getting-started):

> Please do not contact Microsoft for fork-specific issues. If you believe an issue exists in the upstream SDK release itself, report it through official Microsoft channels and include a minimal reproduction using the upstream package.
