// lib/utils/performance_config.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class PerformanceConfig {
  static void optimizeForVideo() {
    // Nonaktifkan debug painting untuk release mode
    if (kReleaseMode) {
      // Optimasi untuk video playback
      SystemChannels.platform.invokeMethod(
        'SystemChrome.setApplicationSwitcherDescription',
        {'label': 'Video Player', 'primaryColor': 0xFF000000},
      );
    }
  }

  static void resetSystemUI() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
}
