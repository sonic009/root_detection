// You have generated a new plugin project without specifying the `--platforms`
// flag. A plugin project with no platform support was generated. To add a
// platform, run `flutter create -t plugin --platforms <platforms> .` under the
// same directory. You can also find a detailed instruction on how to add
// platforms in the `pubspec.yaml` at
// https://flutter.dev/to/pubspec-plugin-platforms.

import 'root_detection_platform_interface.dart';
import 'dart:async';
import 'package:flutter/services.dart';

class RootDetectionPlugin {
  static const MethodChannel _channel = MethodChannel(
    'dev.ashwani.app/root_detection',
  );

  /// Check Platform Version
  Future<String?> getPlatformVersion() {
    return RootDetectionPlatform.instance.getPlatformVersion();
  }

  /// Check if App Attest is supported on this device
  static Future<bool> isSupported() async {
    return await _channel.invokeMethod('isSupported');
  }

  /// Generates a new App Attest key
  static Future<String> generateKey() async {
    return await _channel.invokeMethod('generateKey');
  }

  /// Performs attestation on the generated key
  static Future<String> attest({
    required String keyId,
    required List<int> challenge,
  }) async {
    return await _channel.invokeMethod('attest', {
      "keyId": keyId,
      "challenge": challenge,
    });
  }

  /// Generates an assertion (used for runtime integrity)
  static Future<String> generateAssertion({
    required String keyId,
    required List<int> challenge,
  }) async {
    return await _channel.invokeMethod('assertion', {
      "keyId": keyId,
      "challenge": challenge,
    });
  }

  Future<String> getPlayIntegrityToken(String nonce) {
    return RootDetectionPlatform.instance.getIntegrityToken(nonce);
  }
}
