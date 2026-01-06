/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🎯 Dart imports:
import 'dart:convert';
import 'dart:io';

// 🌎 Project imports:
import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:clarity_flutter/src/clarity_constants.dart';
import 'package:clarity_flutter/src/helpers/services/retriable_http_service.dart';
import 'package:clarity_flutter/src/helpers/telemetry_tracker.dart';
import 'package:clarity_flutter/src/models/project_config.dart';
import 'package:clarity_flutter/src/models/session/page_metadata.dart';
import 'package:clarity_flutter/src/models/telemetry/telemetry.dart';
import 'package:clarity_flutter/src/registries/environment_registry.dart';
import 'package:clarity_flutter/src/utils/http_utils.dart';
import 'package:clarity_flutter/src/utils/log_utils.dart';

class TelemetryService extends RetriableHttpService {
  TelemetryService() {
    if (TelemetryTracker.shouldTrackTelemetry) {
      _reportUrl =
          EnvRegistry.ensureInitialized().getItem<ProjectConfig>(EnvRegistryKey.projectConfig)?.reportUrl ??
          ClarityConstants.fallbackReportUrl;
    }
    _projectId = EnvRegistry.ensureInitialized().getItem<ClarityConfig>(EnvRegistryKey.clarityConfig)!.projectId;
  }

  late final String? _reportUrl;
  late final String _projectId;

  Future<bool> reportTelemetryItem(
    TelemetryItem item, {
    PageMetadata? pageMetadata,
  }) {
    if (item is MetricDetails) {
      return reportMetrics([MetricAccumulator(item.key)..add(item.value)]);
    } else if (item is ErrorDetails) {
      return reportError(item, pageMetadata: pageMetadata);
    }
    // Unexpected type of Telemetry
    return Future.value(false);
  }

  Future<bool> reportMetrics(List<MetricAccumulator> metrics) async {
    final metricsReportUrl = _getMetricReportUrl(_projectId);
    if (metricsReportUrl == null) return false;

    try {
      final serializedMetrics = jsonEncode(metrics.map((m) => m.toJson()).toList());
      final response = await HttpUtils.post(
        Uri.parse(metricsReportUrl),
        headers: _getHeaders(),
        data: utf8.encode(serializedMetrics),
        retryPolicy: retryPolicy,
      );
      return HttpUtils.isSuccessCode(response.statusCode);
    } on Object catch (e) {
      Logger.warn?.out('Error when uploading Metrics Telemetry, $e');
      return false;
    }
  }

  Future<bool> reportError(
    ErrorDetails errorDetails, {
    PageMetadata? pageMetadata,
  }) async {
    if (_reportUrl == null) return false;
    try {
      final serializedError = jsonEncode(errorDetails.toJson(pageMetadata));

      final response = await HttpUtils.post(
        Uri.parse(_reportUrl),
        headers: _getHeaders(),
        data: utf8.encode(serializedError),
        retryPolicy: retryPolicy,
      );
      return HttpUtils.isSuccessCode(response.statusCode);
    } on Object catch (e) {
      Logger.warn?.out('Error when uploading Error Telemetry, $e');
      return false;
    }
  }

  Map<String, String> _getHeaders() => {
    HttpHeaders.contentTypeHeader: 'application/json',
  };

  String? _getMetricReportUrl(String projectId) {
    if (_reportUrl == null) return null;
    final url = Uri.parse(_reportUrl);
    final route = ClarityConstants.metricsPostRoute.replaceAll('{pid}', projectId);
    return '${url.scheme}://${url.host}/$route';
  }
}
