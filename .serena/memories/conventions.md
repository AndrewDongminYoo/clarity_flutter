# Conventions

- Keep scope surgical; do not change public exports in `lib/clarity_flutter.dart` unless explicitly requested.
- Dart files commonly start with Microsoft copyright/MIT header plus `library;`.
- Imports are grouped by `import_sorter`-style section comments for Dart, Flutter, package, and project imports; preserve the existing grouping style in edited files.
- Public API methods in `Clarity` are thin static facade methods delegating to `ClarityManager`; UI-isolate and privacy/PII remarks in docs are intentional.
- `ClarityConfig.userId` is deprecated; new user identity work should prefer `Clarity.setCustomUserId` unless compatibility requires otherwise.
- Many payload/display/text/view models implement `IProtoModel<T>` or `IProtoPageEventModel<T>` and expose `toProtobufInstance`; keep protobuf conversion explicit and testable.
- Display command enum ordering matters: `CommandTypeExtension.toProtobufType()` maps by enum `index` into generated protobuf enum values.
- Do not hand-edit generated outputs under `lib/src/models/generated`, `lib/src/native/generated`, `android/src/main/kotlin/com/microsoft/clarity/generated`, or `ios/clarity_flutter/Sources/clarity_flutter/generated`; edit source specs and regenerate.
- `Proto/MutationPayload.proto` and `proto/MutationPayload.proto` both exist; avoid case-only assumptions on macOS. The Makefile's protobuf generation path uses uppercase `Proto`.
- Korean comments in scripts are intentional; do not translate comments or user-facing strings as cleanup.
