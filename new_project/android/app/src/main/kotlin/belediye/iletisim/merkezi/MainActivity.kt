package belediye.iletisim.merkezi

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

class MainActivity: FlutterActivity() {
    private val CHANNEL = "belediye.iletisim.merkezi/notification"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        
        // Method channel kurulumu
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getNotificationData") {
                // Bildirim verilerini al
                val intent = activity.intent
                val notificationData = getNotificationData(intent)
                result.success(notificationData)
            } else if (call.method == "clearNotificationData") {
                // Bildirim verilerini temizle
                clearNotificationData()
                result.success(true)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getNotificationData(intent: Intent): Map<String, String>? {
        val extras = intent.extras ?: return null
        val data = HashMap<String, String>()
        
        // Bildirim verileri varsa al
        if (extras.containsKey("notification_id")) {
            extras.keySet().forEach { key ->
                extras.get(key)?.toString()?.let { value ->
                    data[key] = value
                }
            }
            return data
        }
        return null
    }

    private fun clearNotificationData() {
        // Intent verilerini temizle
        activity.intent.removeExtra("notification_id")
    }
}