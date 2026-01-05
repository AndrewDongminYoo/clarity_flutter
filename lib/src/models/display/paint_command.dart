/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// Project imports:
import 'package:clarity_flutter/src/models/display/display.dart';

abstract class PaintCommand extends DisplayCommand {
  PaintCommand(this.paintHashcode, CommandType type) : super(type);
  int paintHashcode;
  int? paintIndex;
}
