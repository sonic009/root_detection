🧩 root_detection

A lightweight Flutter plugin to detect rooted (Android) / jailbroken (iOS) devices and improve app security with help of your server.


✨ Features
- Root/jailbreak detection on Android & iOS
- Small footprint, fast checks
- Simple async API
- Android 8+ and iOS 15.6+ support


Table of contents
- Installation
- Usage
- API
- Platform notes
- Example
- Notes/Security considerations
- Issues & Contributions
- License


🚀 Installation

Add this to your pubspec.yaml:

dependencies:
  root_detection: ^1.0.0


🤖 Run:
  flutter pub get
  


🔧 Usage

import 'package:root_detection/root_detection_plugin.dart';

final isSupported = await RootDetectionPlugin.isSupported();

final keyId = await RootDetectionPlugin.generateKey();

final token = await RootDetectionPlugin.getPlayIntegrityToken(
        nonce: nonce,
        gcProjectNumber: "gcProjectNumber", // your Google Cloud project number
      );


 
🔑 API (summary)

- isSupported(): Future<bool> — checks runtime support
- generateKey(): Future<String> — creates or returns a key identifier
- getPlayIntegrityToken({required String nonce, required String gcProjectNumber}): Future<String> — Android Play Integrity token   


🚉 Platform notes

- Android: Uses Play Integrity (when available) and multiple heuristics for rooting detection. Provide Google Cloud project number to obtain tokens.

- iOS: Uses common jailbreak indicators. No platform can guarantee 100% detection.


📦 Example

- See the /example folder for a minimal working app demonstrating integration and error handling.


⚠️ Note/Security considerations

- Root detection is not 100% foolproof
- Use this as an extra security layer


🐞 Issues & Contributions

Feel free to:
- Report bugs
- Open pull requests
- Suggest features
👉 GitHub: https://github.com/sonic009/root_detection


📄 License

MIT License
© 2026 Ashwani