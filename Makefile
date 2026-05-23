DART := dart
FLUTTER := flutter
PROTOC := protoc
PROTO_DIR := Proto
GEN_DIR   := lib/src/models/generated

gen_json:
	@echo "Generating Json stubs..."
	@$(DART) run build_runner build --delete-conflicting-outputs
	@echo "Json stubs generated!"

gen_protobuf:
	@echo "Generating Dart protobuf stubs..."
	$(PROTOC) \
	  --dart_out=$(GEN_DIR) \
	  -I=$(PROTO_DIR) \
	  $(PROTO_DIR)/*.proto
	@echo "Dart protobuf stubs generated!"

gen_pigeon:
	@echo "Generating Pigeon stubs (Dart/Kotlin/Swift)..."
	@$(DART) run pigeon --input pigeons/messages.dart
	@echo "Pigeon stubs generated!"
