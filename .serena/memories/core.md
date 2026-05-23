# Core

- Flutter plugin package `clarity_flutter`; README describes official Microsoft Clarity Flutter SDK, but `pubspec.yaml` has `publish_to: none` for an unofficial fork.
- Public package entrypoint is `lib/clarity_flutter.dart`; it exports only `Clarity`, `ClarityWidget`, `ClarityMask`, `ClarityUnmask`, `ClarityConfig`, and `LogLevel`. Preserve this public surface unless API change is explicit.
- Runtime source map:
  - `lib/src/core/clarity_core.dart`: public `Clarity` facade and internal `ClarityManager` session lifecycle/control APIs.
  - `lib/src/widgets`: `ClarityWidget` initialization wrapper plus masking widgets.
  - `lib/src/managers`: session, capture, upload, asset, font, live session orchestration.
  - `lib/src/helpers` and `lib/src/helpers/services`: snapshot/canvas/view hierarchy processing, gesture processing, ingest, telemetry, retrying HTTP.
  - `lib/src/models`: config/consent/network/low-end/file-store models plus display, text, view hierarchy, ingest, telemetry, session, asset, isolate, capture models.
  - `lib/src/native`: Dart platform facade/channel wrappers plus generated Pigeon messages.
  - `lib/src/models/generated`: generated protobuf/json artifacts.
- Tests are focused unit tests under `test/models`, `test/utils`, and `test/registries`; no broad app/integration suite was observed.
- Native bridge and generation details: `mem:native/core`.
- Toolchain/version pins: `mem:tech_stack`.
- Local commands: `mem:suggested_commands`.
- Style and code conventions: `mem:conventions`.
- Done criteria for coding tasks: `mem:task_completion`.
