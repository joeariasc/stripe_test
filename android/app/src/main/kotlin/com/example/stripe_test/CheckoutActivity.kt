package com.example.stripe_test

import android.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.Button
import android.widget.Toast
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.example.stripe_test.adapters.CartItemsAdapter
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import com.stripe.android.PaymentConfiguration
import com.stripe.android.paymentsheet.PaymentSheet
import com.stripe.android.paymentsheet.PaymentSheetResult
import com.stripe.android.paymentsheet.addresselement.AddressDetails
import com.stripe.android.paymentsheet.addresselement.AddressLauncher
import com.stripe.android.paymentsheet.addresselement.AddressLauncherResult
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel
import okhttp3.Call
import okhttp3.Callback
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import okhttp3.Response
import okio.IOException
import org.json.JSONObject
import java.util.concurrent.TimeUnit

class CheckoutActivity : AppCompatActivity() {
    companion object {
        private const val TAG = "CheckoutActivity"
    }

    private lateinit var recyclerView: RecyclerView
    private lateinit var cartItemsAdapter: CartItemsAdapter

    private lateinit var backedUrl: String
    private lateinit var paymentAmount: String
    private lateinit var itemsList: List<List<String>>

    private lateinit var paymentIntentClientSecret: String
    private lateinit var paymentSheet: PaymentSheet

    private lateinit var payButton: Button

    private lateinit var addressLauncher: AddressLauncher

    private var shippingDetails: AddressDetails? = null

    private lateinit var addressButton: Button

    private lateinit var publishableKey: String

    private val addressConfiguration = AddressLauncher.Configuration(
        additionalFields = AddressLauncher.AdditionalFieldsConfiguration(
            phone = AddressLauncher.AdditionalFieldsConfiguration.FieldConfiguration.REQUIRED
        ),
        allowedCountries = setOf("US", "CA", "GB"),
        title = "Shipping Address",

        )

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_checkout)

        recyclerView = findViewById(R.id.cart_items_recycler_view)
        recyclerView.layoutManager = LinearLayoutManager(this)

        val carItems = mutableListOf<CartItem>()

        intent.getStringExtra(JSON_CAR_ITEMS)?.let { cartItemsJson ->
            val type = object : TypeToken<List<List<String>>>() {}.type
            itemsList = Gson().fromJson(cartItemsJson, type)
            Log.d(TAG, "itemsList => $itemsList")
            itemsList.map { carItems.add(CartItem(it[0], it[1])) }
        }

        cartItemsAdapter = CartItemsAdapter(carItems)
        recyclerView.adapter = cartItemsAdapter

        publishableKey = intent.getStringExtra(PUBLISHABLE_KEY) ?: ""
        backedUrl = intent.getStringExtra(BACKEND_URL) ?: ""
        paymentAmount = intent.getStringExtra(AMOUNT) ?: ""

        PaymentConfiguration.init(applicationContext, publishableKey)

        // Hook up the pay button
        payButton = findViewById(R.id.pay_button)
        payButton.setOnClickListener(::onPayClicked)
        payButton.isEnabled = false

        paymentSheet = PaymentSheet(activity = this, ::onPaymentSheetResult)

        //Hook up the address button
        addressButton = findViewById(R.id.address_button)
        addressButton.setOnClickListener(::onAddressClicked)
        addressButton.isEnabled = false

        addressLauncher = AddressLauncher(this, ::onAddressLauncherResult)

        fetchPaymentIntent()
    }

    private fun fetchPaymentIntent() {
        val url = "${backedUrl}/api/payment"

        val shoppingCartContent = """
            {
                "items": [
                    {"id":"xl-tshirt"}
                ],
                "amount": "$paymentAmount"
            }
        """

        val mediaType = "application/json; charset=utf-8".toMediaType()

        val body = shoppingCartContent.toRequestBody(mediaType)
        val request = Request.Builder().url(url).post(body).build()

        val client = OkHttpClient.Builder().connectTimeout(20, TimeUnit.SECONDS)
            .readTimeout(20, TimeUnit.SECONDS).build()

        client.newCall(request).enqueue(object : Callback {
            override fun onFailure(call: Call, e: IOException) {
                showAlert("Failed to load data", "Error: $e")
            }

            override fun onResponse(call: Call, response: Response) {
                if (!response.isSuccessful) {
                    showAlert("Failed to load page", "Error: $response")
                } else {
                    val responseData = response.body?.string()
                    val responseJson = responseData?.let { JSONObject(it) } ?: JSONObject()
                    paymentIntentClientSecret = responseJson.getString("clientSecret")
                    runOnUiThread { payButton.isEnabled = true }
                    Log.i(TAG, "Retrieved PaymentIntent")
                }
            }
        })
    }

    private fun showAlert(title: String, message: String? = null) {
        runOnUiThread {
            val builder = AlertDialog.Builder(this).setTitle(title).setMessage(message)
            builder.setPositiveButton("Ok", null)
            builder.create().show()
        }
    }

    private fun showToast(message: String) {
        runOnUiThread {
            Toast.makeText(this, message, Toast.LENGTH_LONG).show()
        }
    }

    private fun onPayClicked(view: View) {
        val configuration = PaymentSheet.Configuration("Example, Inc.")

        // Present Payment Sheet
        paymentSheet.presentWithPaymentIntent(paymentIntentClientSecret, configuration)
    }

    private fun onAddressClicked(view: View) {
        addressLauncher.present(
            publishableKey = publishableKey, configuration = addressConfiguration
        )
    }

    private fun onPaymentSheetResult(paymentResult: PaymentSheetResult) {
        when (paymentResult) {
            is PaymentSheetResult.Completed -> {
                showToast("Payment complete!")
                val flutterEngine = FlutterEngineCache.getInstance().get("my_engine_id")
                if (flutterEngine != null) {
                    MethodChannel(
                        flutterEngine.dartExecutor,
                        METHOD_CHANNEL_NAME
                    ).invokeMethod("paymentSuccess", null)
                }
                finish()
            }

            is PaymentSheetResult.Canceled -> {
                Log.i(TAG, "Payment canceled!")
            }

            is PaymentSheetResult.Failed -> {
                showAlert("Payment failed", paymentResult.error.localizedMessage)
            }
        }
    }

    private fun onAddressLauncherResult(result: AddressLauncherResult) {
        // TODO: Handle result and update your UI
        when (result) {
            is AddressLauncherResult.Succeeded -> {
                shippingDetails = result.address
            }

            is AddressLauncherResult.Canceled -> {
                // TODO: Handle cancel
            }
        }
    }
}