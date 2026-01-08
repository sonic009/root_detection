import Flutter
import UIKit
import DeviceCheck
import CryptoKit

@available(iOS 14.0, *)
public class RootDetectionPlugin: NSObject, FlutterPlugin {

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "dev.ashwani.app/root_detection",
            binaryMessenger: registrar.messenger()
        )
        let instance = RootDetectionPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        switch call.method {
          case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)  

          case "isSupported":
            result(DCAppAttestService.shared.isSupported)

          case "generateKey":
            handleGenerateKey(result: result)

          case "attest":
            handleAttestation(call: call, result: result)

          case "assertion":
            handleAssertion(call: call, result: result)

          default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func handleGenerateKey(result: @escaping FlutterResult) {
        guard DCAppAttestService.shared.isSupported else {
            result(FlutterError(code: "NOT_SUPPORTED",
                                message: "App Attest not supported",
                                details: nil))
            return
        }

        DCAppAttestService.shared.generateKey { keyId, error in
            if let keyId = keyId {
                result(keyId)
            } else {
                result(FlutterError(code: "GEN_FAIL",
                                    message: error?.localizedDescription,
                                    details: nil))
            }
        }
    }

    private func handleAttestation(call: FlutterMethodCall,
                                   result: @escaping FlutterResult) {

        guard
            let args = call.arguments as? [String: Any],
            let keyId = args["keyId"] as? String,
            let challenge = args["challenge"] as? String //FlutterStandardTypedData
        else {
            result(FlutterError(code: "BAD_ARGS",
                                message: "Invalid arguments",
                                details: nil))
            return
        }

        let challengeHash = SHA256.hash(data: challenge.data(using: .utf8))

        DCAppAttestService.shared.attestKey(
            keyId,
            clientDataHash: Data(challengeHash)
        ) { attestation, error in

            if let attestation = attestation {
                result(attestation.base64EncodedString())
            } else {
                result(FlutterError(code: "ATTEST_FAIL",
                                    message: error?.localizedDescription,
                                    details: nil))
            }
        }
    }

    private func handleAssertion(call: FlutterMethodCall,
                                 result: @escaping FlutterResult) {

        guard
            let args = call.arguments as? [String: Any],
            let keyId = args["keyId"] as? String,
            let challenge = args["challenge"] as? String //FlutterStandardTypedData
        else {
            result(FlutterError(code: "BAD_ARGS",
                                message: "Invalid arguments",
                                details: nil))
            return
        }

        let challengeHash = SHA256.hash(data: challenge.data(using: .utf8))

        DCAppAttestService.shared.generateAssertion(
            keyId,
            clientDataHash: Data(challengeHash)
        ) { assertion, error in

            if let assertion = assertion {
                result(assertion.base64EncodedString())
            } else {
                result(FlutterError(code: "ASSERT_FAIL",
                                    message: error?.localizedDescription,
                                    details: nil))
            }
        }
    }
}
