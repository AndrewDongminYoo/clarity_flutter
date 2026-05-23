# Suggested Commands

- Install/update Dart dependencies: `flutter pub get`.
- Format Dart: `dart format .`.
- Analyze Dart/Flutter: `flutter analyze`.
- Run all unit tests: `flutter test`.
- Run a focused test file: `flutter test test/<path>_test.dart`.
- Generate JSON serializers: `make gen_json` or `dart run build_runner build --delete-conflicting-outputs`.
- Generate Pigeon Dart/Kotlin/Swift bridge code: `make gen_pigeon` or `dart run pigeon --input pigeons/messages.dart`.
- Generate Dart protobuf stubs: `make gen_protobuf`; the Makefile uses uppercase `Proto` as source.
- Reconstruct lowercase proto from generated pbjson: `uv venv`, `uv pip install -r scripts/requirements.txt`, then `uv run python scripts/reconstruct_proto_from_pbjson.py lib/src/models/generated/MutationPayload.pbjson.dart -o proto/MutationPayload.proto`.
- Run Trunk formatting/checks for non-Dart repo hygiene: `trunk fmt`, `trunk check`; Dart linting is disabled in `.trunk/trunk.yaml`.
- Inspect worktree state before edits/commit: `git status --short`.
