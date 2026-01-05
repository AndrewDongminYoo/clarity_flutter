/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/display/display_command.dart';

abstract class ViewDebuggingAnnotation extends DisplayCommand {
  ViewDebuggingAnnotation(super.type);
}
