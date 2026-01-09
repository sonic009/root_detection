import 'root_detection_platform_interface.dart';

class RootDetection {
  Future<String?> getPlatformVersion() {
    return RootDetectionPlatform.instance.getPlatformVersion();
  }
}
