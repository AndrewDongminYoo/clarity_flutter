/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

enum ConsentSource { implicit, api, gcm }

final class ConsentStatus {
  const ConsentStatus({required this.source, required this.adsStorage, required this.analyticsStorage});
  final ConsentSource source;
  final bool adsStorage;
  final bool analyticsStorage;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConsentStatus &&
          source == other.source &&
          adsStorage == other.adsStorage &&
          analyticsStorage == other.analyticsStorage;

  @override
  int get hashCode => Object.hash(source, adsStorage, analyticsStorage);

  @override
  String toString() => 'ConsentStatus(source: $source, adsStorage: $adsStorage, analyticsStorage: $analyticsStorage)';
}
