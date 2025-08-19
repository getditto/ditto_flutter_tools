package live.ditto.ditto_flutter_tools

import android.content.Context
import android.content.pm.PackageManager
import android.net.wifi.WifiManager
import android.net.wifi.aware.WifiAwareManager
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class DittoFlutterToolsPlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel : MethodChannel
  private lateinit var context: Context

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "ditto_wifi_permissions")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "checkAndroidWifiPermissions" -> {
        checkAndroidWifiPermissions(result)
      }
      "checkAndroidWifiAwarePermissions" -> {
        checkAndroidWifiAwarePermissions(result)
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private fun checkAndroidWifiPermissions(result: Result) {
    // Run on background thread to avoid blocking UI
    CoroutineScope(Dispatchers.IO).launch {
      try {
        val sdkVersion = Build.VERSION.SDK_INT
        
        // Check WiFi status
        val wifiManager = context.applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
        val isWifiEnabled = wifiManager.isWifiEnabled
        
        val message = if (isWifiEnabled) {
            "API $sdkVersion - WiFi is enabled"
          } else {
            "API $sdkVersion - WiFi is disabled"
          }
        
        // Switch back to main thread for result
        CoroutineScope(Dispatchers.Main).launch {
          result.success(mapOf(
            "isConfigured" to isWifiEnabled,
            "message" to message
          ))
        }
        
      } catch (e: Exception) {
        CoroutineScope(Dispatchers.Main).launch {
          result.success(mapOf(
            "isConfigured" to false,
            "message" to "Error checking WiFi: ${e.message}"
          ))
        }
      }
    }
  }

  private fun checkAndroidWifiAwarePermissions(result: Result) {
    // Run on background thread to avoid blocking UI
    CoroutineScope(Dispatchers.IO).launch {
      try {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
          CoroutineScope(Dispatchers.Main).launch {
            result.success(mapOf(
              "isConfigured" to false,
              "message" to "WiFi Aware requires Android 8.0+ (API 26+)"
            ))
          }
          return@launch
        }
        
        val packageManager = context.packageManager
        
        // Check if WiFi Aware is supported
        val isWifiAwareSupported = packageManager.hasSystemFeature(PackageManager.FEATURE_WIFI_AWARE)
        
        if (!isWifiAwareSupported) {
          CoroutineScope(Dispatchers.Main).launch {
            result.success(mapOf(
              "isConfigured" to false,
              "message" to "WiFi Aware is not supported on this device"
            ))
          }
          return@launch
        }
        
        // Check WiFi Aware Manager availability
        val wifiAwareManager = context.getSystemService(Context.WIFI_AWARE_SERVICE) as? WifiAwareManager
        val isWifiAwareAvailable = wifiAwareManager?.isAvailable == true
        
        val message = if (isWifiAwareAvailable) {
          "WiFi Aware is available"
        } else {
          "WiFi Aware is supported but not currently available"
        }
        
        CoroutineScope(Dispatchers.Main).launch {
          result.success(mapOf(
            "isConfigured" to isWifiAwareAvailable,
            "message" to message
          ))
        }
        
      } catch (e: Exception) {
        CoroutineScope(Dispatchers.Main).launch {
          result.success(mapOf(
            "isConfigured" to false,
            "message" to "Error checking WiFi Aware: ${e.message}"
          ))
        }
      }
    }
  }
}