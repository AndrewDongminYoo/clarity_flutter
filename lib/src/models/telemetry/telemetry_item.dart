/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

abstract class TelemetryItem {
  const TelemetryItem();
}

enum ErrorType {
  Initialization,
  ScreenCapturing,
  PartialScreenCapturing,
  ObservedEventProcessing,
  SessionEventProcessing,
  PayloadProcessing,
  CapturingTouchEvent,
  UploadSession,
  SettingCustomTag,
  SettingOnSessionStartedCallback,
  GettingCurrentSessionUrl,
  SendingCustomEvent,
  SettingCurrentScreenName,
  PausingClarity,
  ResumingClarity,
  StartNewClaritySession,
}

enum MetricKey {
  Clarity_RepaintTriggered,
  Clarity_UploadAssetBytes,
  Clarity_UploadSessionSegmentBytes,
  Clarity_CapturingThrottled,
  Clarity_PayloadQueueCongestion,
}
