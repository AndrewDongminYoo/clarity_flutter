/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/events/session_event.dart';
import 'package:clarity_flutter/src/models/ingest/analytics/analytics_event.dart';
import 'package:clarity_flutter/src/utils/data_utils.dart';

// ignore_for_file: constant_identifier_names
enum Dimension {
  UserAgent,
  Url,
  Referrer,
  PageTitle,
  NetworkHosts,
  SchemaType,
  ProductBrand,
  ProductAvailability,
  AuthorName,
  Language,
  ProductName,
  ProductCategory,
  ProductSku,
  ProductCurrency,
  ProductCondition,
  TabId,
  PageLanguage,
  DocumentDirection,
  Headline,
  MetaType,
  MetaTitle,
  Generator,
  Platform,
  PlatformVersion,
  Brand,
  Model,
}

class DimensionEvent extends AnalyticsEvent {
  DimensionEvent(int timestamp, this.dimensions) : super(timestamp, EventType.Dimension);
  final Map<Dimension, String> dimensions;

  @override
  EventType get type => EventType.Dimension;

  @override
  String serialize(int pageTimestamp) {
    final buffer = StringBuffer();
    buffer.write('[${relativeTimestamp(pageTimestamp)},${type.customOrdinal}');

    dimensions.forEach((dimension, value) {
      final escapedValue = DataUtils.escape(value);
      buffer.write(',${dimension.index},["$escapedValue"]');
    });

    buffer.write(']');
    return buffer.toString();
  }
}
