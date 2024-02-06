package com.example.stripe_test

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity : FlutterActivity() {
    private val METHOD_CHANNEL_NAME: String = "co.wawand/stripe"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            METHOD_CHANNEL_NAME
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "test" -> {
                    val args = call.arguments as? Map<String, String>
                    result.success("Android Say Hello ${args?.get("name")}")
                }
            }
        }
    }

    private fun initializeStripe(name: String?): String {
        return name ?: "Hey from Android!"
    }
}
