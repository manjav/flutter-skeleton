package sources

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import sources.util.IabResult
import sources.util.Inventory
import sources.util.Purchase
import com.google.gson.Gson

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.tcg.fruitcraft.trading.card.game.battle/payment"
    private lateinit var channel: MethodChannel
    private var mHelper: IabHelper? = null
    private val gson: Gson = Gson()

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "init") {
                val enableDebugLogging = call.argument<Boolean>("enableDebugLogging")
                val storePackageName = call.argument<String>("storePackageName")
                val bindUrl = call.argument<String>("bindUrl")
                mHelper = IabHelper(this, storePackageName, bindUrl)
                mHelper?.enableDebugLogging(enableDebugLogging == true)
                mHelper?.startSetup {
                    result.success(gson.toJson(it, IabResult::class.java))
                }
            } else if (call.method == "launchPurchaseFlow") {
                val sku = call.argument<String>("sku")
                val payload = call.argument<String>("payload")
                val onIabPurchaseFinishedListener =
                    IabHelper.OnIabPurchaseFinishedListener { purchaseResult: IabResult, purchase: Purchase? ->
                        result.success(
                            mapOf(
                                "result" to gson.toJson(purchaseResult, IabResult::class.java),
                                "purchase" to gson.toJson(purchase, Purchase::class.java)
                            )
                        )
                    }
                mHelper?.launchPurchaseFlow(
                    this.activity,
                    sku,
                    onIabPurchaseFinishedListener,
                    payload
                )
            } else if (call.method == "consume") {
                val purchase =
                    gson.fromJson(call.argument<String>("purchase"), Purchase::class.java)
                mHelper?.consumeAsync(purchase) { p: Purchase?, consumeResult: IabResult ->
                    result.success(
                        mapOf(
                            "result" to gson.toJson(consumeResult, IabResult::class.java),
                            "purchase" to gson.toJson(p, Purchase::class.java)
                        )
                    )
                }
            } else if (call.method == "getPurchase") {
                val sku = call.argument<String>("sku")
                val querySkuDetails = call.argument<Boolean>("querySkuDetails")
                mHelper?.queryInventoryAsync(querySkuDetails == true, arrayListOf(sku))
                { iabResult: IabResult, inventory: Inventory? ->
                    val purchase = inventory?.getPurchase(sku)
                    result.success(
                        mapOf(
                            "result" to gson.toJson(iabResult, IabResult::class.java),
                            "purchase" to gson.toJson(purchase, Purchase::class.java)
                        )
                    )
                }
            } else if (call.method == "queryInventory") {
                val querySkuDetails = call.argument<Boolean>("querySkuDetails")
                val skus = call.argument<List<String>>("skus")
                mHelper?.queryInventoryAsync(querySkuDetails == true, skus)
                { iabResult: IabResult, inventory: Inventory? ->
                    result.success(
                        mapOf(
                            "result" to gson.toJson(iabResult, IabResult::class.java),
                            "inventory" to gson.toJson(inventory, Inventory::class.java)
                        )
                    )
                }
            } else if (call.method == "dispose") {
                mHelper?.dispose()
            } else if (call.method == "subscriptionsSupported") {
                result.success(mHelper?.subscriptionsSupported())
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        channel.setMethodCallHandler(null)
        mHelper?.dispose()
        mHelper = null
        super.onDestroy()
    }
}
