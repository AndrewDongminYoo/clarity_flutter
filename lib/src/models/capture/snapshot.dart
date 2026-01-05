/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

import 'package:flutter/rendering.dart';
import '../../managers/base_session_manager.dart';
import 'edit_text_info.dart';
import 'native_image_wrapper.dart';
import '../view_hierarchy/view_node.dart';

import '../display/display.dart';
import '../events/observed_event.dart';

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
