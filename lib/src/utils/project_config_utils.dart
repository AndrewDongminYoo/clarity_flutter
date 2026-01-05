// 📦 Package imports:
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:system_info2/system_info2.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/clarity_constants.dart';
import 'package:clarity_flutter/src/models/project_config.dart';
import 'package:clarity_flutter/src/registries/environment_registry.dart';
import 'package:clarity_flutter/src/utils/log_utils.dart';

class ProjectConfigUtils {
  ProjectConfigUtils._();

  static const int bytesInGB = 1024 * 1024 * 1024;

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
    final totalMemoryMB = SysInfo.getTotalPhysicalMemory() / ProjectConfigUtils.bytesInGB;

    return totalMemoryMB < ClarityConstants.lowEndMemoryThresholdGB;
  }

  static bool isUploadingOverNetworkAllowed(List<ConnectivityResult> result) {
    final allowMeteredNetworkConfig = EnvRegistry.ensureInitialized()
        .getItem<ProjectConfig>(EnvRegistryKey.projectConfig)!
        .network
        .allowMeteredNetwork;
    final isCurrentNetworkWIFI = result.contains(ConnectivityResult.wifi);
    final isCurrentNetworkMobile = result.contains(ConnectivityResult.mobile);

    return isCurrentNetworkWIFI || (allowMeteredNetworkConfig && isCurrentNetworkMobile);
  }
}
