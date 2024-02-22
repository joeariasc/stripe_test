package com.example.stripe_test

import android.content.Intent
import com.google.gson.Gson
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity : FlutterActivity() {
    private lateinit var result: MethodChannel.Result

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            METHOD_CHANNEL_NAME
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "test" -> {
                    val args = call.arguments as? Map<*, *>
                    //publishableKey = args?.get("stripePublishableKey") ?: ""
                    //result.success("Android Say Hello ${args?.get("name")}")
                    startCheckoutActivity(args, result)
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun startCheckoutActivity(args: Map<*, *>?, result: MethodChannel.Result) {
        val carItems = args?.get(CAR_ITEMS) as List<*>
        val jsonCartItems = Gson().toJson(carItems)
        val intent = Intent(this, CheckoutActivity::class.java).apply {
            putExtra(PUBLISHABLE_KEY, args[STRIPE_PUBLISHABLE_KEY] as String)
            putExtra(BACKEND_URL, args[SERVER_HOST] as String)
            putExtra(AMOUNT, args[AMOUNT] as String)
            putExtra(JSON_CAR_ITEMS, jsonCartItems)
        }
        this.result = result
        startActivityForResult(intent, 120)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == 120 && resultCode == RESULT_OK && data != null) {
            val resultString = data.getStringExtra("isSuccess")
            result.success(resultString)
        }
    }
}
