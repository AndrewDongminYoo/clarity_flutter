# Task Completion

- Minimum verification for Dart/Flutter code changes:
  1. `dart format .`
  2. `flutter analyze`
  3. `flutter test`
- For narrow changes, a focused `flutter test test/<path>_test.dart` is acceptable during iteration, but run the broader command set before claiming completion unless the user asked for a faster scoped check.
- For generated-model changes:
  - JSON annotated model changes: run `make gen_json`.
  - Pigeon API/native bridge changes: run `make gen_pigeon` and review Dart/Kotlin/Swift generated diffs.
  - Protobuf schema changes: run `make gen_protobuf`; update/reconcile lowercase `proto/MutationPayload.proto` only if the task requires that artifact.
- After generation, rerun `dart format .`, `flutter analyze`, and relevant tests.
- Trunk checks are supplementary for repo hygiene: `trunk fmt` and `trunk check`; they do not replace `flutter analyze` because Trunk disables Dart linting here.
- If Flutter/SDK/toolchain commands cannot run locally, report the exact command attempted and the blocking error; do not mark verification as complete.
