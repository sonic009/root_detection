package com.example.root_detection

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
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
    private val mainHandler = Handler(Looper.getMainLooper())


    override fun onAttachedToEngine(
        @NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding
    ) {
        Log.d("ROOT_PLUGIN", "Plugin attached to engine");
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

                val gcProjectNumber = call.argument<String>("cloudProjectNumber")
                if (gcProjectNumber.isNullOrEmpty()) {
                    result.error("INVALID_GCPROJECTNUMBER", "GC Project Number is required", null)
                    return
                }

                var replied = false

                integrityHelper.requestIntegrityToken(
                    nonce = nonce,
                    cloudProjectNumber = gcProjectNumber,
                    onSuccess = { token ->
                        Log.d("ROOT_PLUGIN", "Token length = ${token.length}");

                        if (!replied) {
                            replied = true
                            mainHandler.post { result.success(token) }
                        }
                    },
                    onError = { error ->
                        if (!replied) {
                            replied = true
                            mainHandler.post {
                                result.error("INTEGRITY_ERROR", error.message, null)
                            }
                        }
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
