import Flutter
import UIKit
import Network
import Foundation

public class DittoFlutterToolsPlugin: NSObject, FlutterPlugin {
  private var pathMonitor: NWPathMonitor!
  private var isWifiEnabled = false

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "ditto_wifi_permissions", binaryMessenger: registrar.messenger())
    let instance = DittoFlutterToolsPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "checkiOSWifiPermissions":
      checkiOSWifiPermissions(result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  private func checkiOSWifiPermissions(result: @escaping FlutterResult) {
    // Check actual WiFi status using NWPathMonitor on background queue
    let monitor = NWPathMonitor(requiredInterfaceType: .wifi)
    let queue = DispatchQueue.global(qos: .background)
    let resultSent: Bool = false

    monitor.pathUpdateHandler = { path in
      let isWifiAvailable = path.status == .satisfied && path.usesInterfaceType(.wifi)
      
      DispatchQueue.main.async {
        var message = ""
        if isWifiAvailable {
          message = "WiFi is available"
        } else {
           message = "WiFi is not available"
        }
        result([
          "isConfigured": isWifiAvailable,
          "message": message
        ])
        resultSent = true
      }
      // Stop monitoring after first check
      monitor.cancel()
    }
    monitor.start(queue: queue)

    // Add timeout to prevent hanging
    DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
      if !resultSent {
        resultSent = true
        monitor.cancel()
        result([
          "isConfigured": false,
          "message": "Timeout checking WiFi status"
        ])
      }
    }
  }
}