package com.example.root_detection

import android.content.Context
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class RootDetectionPlugin : FlutterPlugin, MethodCallHandler {

    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var integrityHelper: PlayIntegrityHelper

    override fun onAttachedToEngine(
        @NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding
    ) {
        channel = MethodChannel(
            flutterPluginBinding.binaryMessenger,
            "dev.ashwani.app/root_detection"
        )
        channel.setMethodCallHandler(this)

        context = flutterPluginBinding.applicationContext
        integrityHelper = PlayIntegrityHelper(context)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {

            "getIntegrityToken" -> {
                val nonce = call.argument<String>("nonce")
                if (nonce.isNullOrEmpty()) {
                    result.error("INVALID_NONCE", "Nonce is required", null)
                    return
                }

                integrityHelper.requestIntegrityToken(
                    nonce = nonce,
                    onSuccess = { token ->
                        result.success(token)
                    },
                    onError = { error ->
                        result.error("INTEGRITY_ERROR", error.message, null)
                    }
                )
            }

            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }

            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(
        @NonNull binding: FlutterPlugin.FlutterPluginBinding
    ) {
        channel.setMethodCallHandler(null)
    }
}
