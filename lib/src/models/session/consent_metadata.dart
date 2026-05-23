/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

class ConsentMetadata {
  const ConsentMetadata({required this.sourceOrdinal, this.adsStorage, this.analyticsStorage, this.cachedGaid});
  factory ConsentMetadata.fromJson(Map<String, dynamic> json) => ConsentMetadata(
    sourceOrdinal: json['sourceOrdinal'] as int? ?? 0,
    adsStorage: json['adsStorage'] as bool?,
    analyticsStorage: json['analyticsStorage'] as bool?,
    cachedGaid: json['cachedGaid'] as String?,
  );

  final int sourceOrdinal;
  final bool? adsStorage;
  final bool? analyticsStorage;
  final String? cachedGaid;

  Map<String, dynamic> toJson() => {
    'sourceOrdinal': sourceOrdinal,
    'adsStorage': adsStorage,
    'analyticsStorage': analyticsStorage,
    'cachedGaid': cachedGaid,
  };
}
