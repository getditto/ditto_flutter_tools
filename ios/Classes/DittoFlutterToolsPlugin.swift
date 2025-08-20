import Flutter
import UIKit
import Network
import Foundation

/// Thread-safe result handler to ensure Flutter result is only sent once
private class ResultHandler {
  private let result: FlutterResult
  private var hasResult = false
  private let lock = NSLock()
  
  init(result: @escaping FlutterResult) {
    self.result = result
  }
  
  func sendResultOnce(_ resultData: [String: Any]) {
    lock.lock()
    defer { lock.unlock() }
    
    if !hasResult {
      hasResult = true
      DispatchQueue.main.async {
        self.result(resultData)
      }
    }
  }
}

public class DittoFlutterToolsPlugin: NSObject, FlutterPlugin {

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
    
    // Use a dispatch_once-like mechanism to ensure result is only sent once
    let resultHandler = ResultHandler(result: result)

    monitor.pathUpdateHandler = { path in
      let isWifiAvailable = path.status == .satisfied && path.usesInterfaceType(.wifi)
      
      // Ensure we only send result once using thread-safe mechanism
      resultHandler.sendResultOnce([
        "isConfigured": isWifiAvailable,
        "message": isWifiAvailable ? "WiFi is available" : "WiFi is not available"
      ])
      
      // Stop monitoring after first check
      monitor.cancel()
    }
    monitor.start(queue: queue)

    // Add timeout to prevent hanging
    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
      resultHandler.sendResultOnce([
        "isConfigured": false,
        "message": "Timeout checking WiFi status"
      ])
      monitor.cancel()
    }
  }
}