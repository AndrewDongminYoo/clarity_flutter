/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🐦 Flutter imports:
import 'package:flutter/rendering.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/managers/base_session_manager.dart';
import 'package:clarity_flutter/src/models/capture/edit_text_info.dart';
import 'package:clarity_flutter/src/models/capture/native_image_wrapper.dart';
import 'package:clarity_flutter/src/models/display/display.dart';
import 'package:clarity_flutter/src/models/events/observed_event.dart';
import 'package:clarity_flutter/src/models/view_hierarchy/view_node.dart';

class Snapshot extends ObservedEvent {
  Snapshot(
    super.timestamp,
    this.deviceTransformationMatrix,
    this.flutterViewId,
    this.keyboardHeight,
    this.userProvidedScreenName,
    this.forceStartNewSession,
    this.forceStartNewSessionCallback,
  );
  Matrix4 deviceTransformationMatrix;
  int flutterViewId;

  List<DisplayCommand> commands = [];
  Map<int, NativeImageWrapper> images = {};
  Map<int, Paint> paints = {};
  ViewNode? root;
  int keyboardHeight;
  EditTextInfo? editTextInfo;
  String? userProvidedScreenName;
  bool forceStartNewSession = false;
  SessionStartedCallback? forceStartNewSessionCallback;

  void addCommand(DisplayCommand command) {
    commands.add(command);
  }
}
