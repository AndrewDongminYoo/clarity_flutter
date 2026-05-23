// 🌎 Project imports:
import 'package:clarity_flutter/src/clarity_constants.dart';
import 'package:clarity_flutter/src/models/project_config.dart';
import 'package:clarity_flutter/src/native/generated/messages.g.dart' as pigeon;
import 'package:clarity_flutter/src/registries/environment_registry.dart';
import 'package:clarity_flutter/src/registries/host_info.dart';
import 'package:clarity_flutter/src/utils/log_utils.dart';

class ProjectConfigUtils {
  ProjectConfigUtils._();

  static const int megabytesInGB = 1024;

  static bool isScreenNameAllowed(String? screenName) {
    if (screenName == null) return true;

    final registry = EnvRegistry.ensureInitialized();
    final screenCapture = registry.getItem<ProjectConfig>(EnvRegistryKey.projectConfig)!.screenCapture;
    final isScreenNameDisallowed = screenCapture.disallowedScreens.contains(screenName);
    if (isScreenNameDisallowed) {
      Logger.info?.out('Screen name $screenName is in the disallowedScreens list');
      return false;
    }
    final isScreenNameAllowed =
        screenCapture.allowedScreens.isEmpty || screenCapture.allowedScreens.contains(screenName);
    if (!isScreenNameAllowed) {
      Logger.info?.out('Screen name $screenName is not in the allowedScreens list');
    }
    return isScreenNameAllowed;
  }

  static bool isLowEndDevice() {
    final hostInfo = EnvRegistry.ensureInitialized().getItem<HostInfo>(EnvRegistryKey.hostInfo);
    final totalMemoryMB = hostInfo?.totalMemory ?? 0;
    if (totalMemoryMB > 0) {
      final totalMemoryGB = totalMemoryMB / ProjectConfigUtils.megabytesInGB;
      return totalMemoryGB < ClarityConstants.lowEndMemoryThresholdGB;
    }

    Logger.warn?.out("Unable to determine total memory of the device. Assuming it's not a low-end device.");
    return false;
  }

  static bool isUploadingOverNetworkAllowed(List<pigeon.ConnectivityType> result) {
    final allowMeteredNetworkConfig = EnvRegistry.ensureInitialized()
        .getItem<ProjectConfig>(EnvRegistryKey.projectConfig)!
        .network
        .allowMeteredNetwork;
    final isCurrentNetworkUnmetered =
        result.contains(pigeon.ConnectivityType.wifi) || result.contains(pigeon.ConnectivityType.ethernet);
    final isCurrentNetworkMobile = result.contains(pigeon.ConnectivityType.mobile);

    return isCurrentNetworkUnmetered || (allowMeteredNetworkConfig && isCurrentNetworkMobile);
  }
}
