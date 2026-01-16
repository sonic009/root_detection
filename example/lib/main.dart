import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:root_detection/root_detection_plugin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'UNKNOWN';
  final _rootDetectionPlugin = RootDetectionPlugin();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  String generateNonce() {
    final random = Random.secure();
    final values = List<int>.generate(32, (_) => random.nextInt(256));
    return values.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _rootDetectionPlugin.getPlatformVersion() ??
          'Unknown platform version';

      setState(() {
        _platformVersion = platformVersion;
      });

      if (mounted == false) return;

      //MARK: Proceed with root detection based on platform if you are sure the minimum OS version is met.
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        proceedWithiOSRootDetection();
      } else if (Theme.of(context).platform == TargetPlatform.android) {
        proceedWithAndroidRootDetection();
      }
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
  }

  //MARK: iOS root detection logic can be implemented here,
  void proceedWithiOSRootDetection() async {
    final isSupported = await RootDetectionPlugin.isSupported();
    developer.log("isSupported: $isSupported", name: "ROOT_DETECTION");

    if (isSupported) {
      final keyId = await RootDetectionPlugin.generateKey();
      developer.log("Generated Key ID: $keyId", name: "ROOT_DETECTION");

      //Get a random challenge from your server in production,
      final challenge = "sample_challenge";

      final attestation = await RootDetectionPlugin.attest(
        keyId: keyId,
        challenge: challenge,
      );
      developer.log("Attestation: $attestation", name: "ROOT_DETECTION");

      //MARK: Use the attestation on your server to verify device integrity before proceeding.
      /*
      final isDeviceIntegrityValid = await verifyAttestationOnServer(attestation);
      if (!isDeviceIntegrityValid) {
        developer.log("Device integrity check failed.", name: "ROOT_DETECTION");
        return;
      }
      */

      final assertion = await RootDetectionPlugin.generateAssertion(
        keyId: keyId,
        challenge: challenge,
      );
      developer.log("Assertion: $assertion", name: "ROOT_DETECTION");
    }
  }

  //MARK: Android root detection logic can be implemented here,
  void proceedWithAndroidRootDetection() async {
    final isSupported = await RootDetectionPlugin.isSupported();
    developer.log("isSupported: $isSupported", name: "ROOT_DETECTION");

    if (isSupported) {
      //NOTE: Get a random nonce from your server in production,
      //NOTE: nonce should be in base64url format without padding,
      final nonce = generateNonce();

      final token = await RootDetectionPlugin.getPlayIntegrityToken(
        nonce: nonce,
        gcProjectNumber: "gcProjectNumber", // your Google Cloud project number
      );

      developer.log(
        "Integrity token received (length: ${token.length})",
        name: "PLAY_INTEGRITY",
      );

      //MARK: Use the token on your server to verify device integrity before proceeding.
      /*
      final isDeviceIntegrityValid = await verifyPlayIntegrityTokenOnServer(token);
      if (!isDeviceIntegrityValid) {
        developer.log("Device integrity check failed.", name: "ROOT_DETECTION");
        return;
      }
      */
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Center(child: Text('Running on: $_platformVersion\n')),
      ),
    );
  }
}
