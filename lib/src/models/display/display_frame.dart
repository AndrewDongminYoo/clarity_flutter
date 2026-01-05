/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

import '../../managers/base_session_manager.dart';
import '../iproto_model.dart';
import '../view_hierarchy/view_hierarchy.dart';
import 'display.dart';
import '../assets/image.dart';
import '../generated/MutationPayload.pb.dart' as mutation_payload;

class DisplayFrame implements IProtoPageEventModel<mutation_payload.DisplayFrameV2> {
  DisplayFrame(
    this.timestamp,
    this.images,
    this.paints,
    this.commands,
    this.screenWidth,
    this.screenHeight,
    this.keyboardHeight,
    this.viewHierarchy,
    this.dpr,
    this.forceStartNewSession,
    this.forceStartNewSessionCallback, {
    this.viewId,
  });
  int timestamp;
  List<Image> images;
  List<Paint> paints;
  List<DisplayCommand> commands;
  int screenWidth;
  int screenHeight;
  int keyboardHeight;
  ViewHierarchy viewHierarchy;
  int? viewId;
  bool forceStartNewSession;
  SessionStartedCallback? forceStartNewSessionCallback;
  double dpr;

  @override
  mutation_payload.DisplayFrameV2 toProtobufInstance(int pageTimestamp) {
    return mutation_payload.DisplayFrameV2(
      timestamp: timestamp.toDouble() - pageTimestamp,
      images: images.map((image) => image.toProtobufInstance()).toList(growable: false),
      paints: paints.map((paint) => paint.toProtobufInstance()).toList(growable: false),
      commands: commands.map((command) => command.toProtobufInstance()).toList(growable: false),
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      keyboardHeight: keyboardHeight,
      viewHierarchy: viewHierarchy.toProtobufInstance(),
      activityId: viewId,
    );
  }
}
