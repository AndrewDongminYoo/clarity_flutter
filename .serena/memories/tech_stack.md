# Tech Stack

- Dart/Flutter plugin package with Android and iOS platform implementations.
- `pubspec.yaml` pins package version `1.9.0`, Dart SDK `^3.12.0`, Flutter `^3.44.0`, and `publish_to: none`.
- Runtime dependencies: Flutter SDK, `fixnum`, `image`, `json_annotation`, `protobuf`, `xxh3`.
- Dev dependencies: `build_runner`, `flutter_lints`, `flutter_test`, `import_sorter`, `json_serializable`, `pigeon`, `very_good_analysis`.
- Analysis extends `package:very_good_analysis/analysis_options.yaml`; `lib/src/models/generated/**` is excluded; formatter page width is 120.
- Android plugin metadata: package/namespace `com.microsoft.clarity`, plugin class `ClarityFlutterPlugin`, `minSdk 21`, compile SDK from Flutter, Java/Kotlin target 17.
- iOS plugin metadata: plugin class `ClarityFlutterPlugin`; Swift package uses tools 5.9, iOS 12.0 minimum, and processes `PrivacyInfo.xcprivacy`.
- Code generation:
  - JSON serialization via `build_runner` and `json_serializable` with custom generated output paths in `build.yaml`.
  - Platform channels via Pigeon spec `pigeons/messages.dart`.
  - Protobuf stubs from `Proto/MutationPayload.proto` into `lib/src/models/generated`.
- Trunk is configured at CLI `1.25.0`; Trunk's `dart` linter is disabled, so Dart checks come from `flutter analyze`.
- CI runs on pull requests to `main` through Very Good Workflows: semantic PR title, markdown spell check, and `flutter_package` with stable Flutter.
