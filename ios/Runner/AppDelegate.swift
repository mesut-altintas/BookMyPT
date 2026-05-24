import Flutter
import UIKit
import FirebaseMessaging

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

  /// Written by APNs callbacks, read via MethodChannel from Flutter.
  private var apnsDiag: String = "not_called_yet"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    // Expose APNs diagnostic to Flutter via MethodChannel.
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "com.bookmypt/native_diag",
        binaryMessenger: controller.binaryMessenger
      )
      channel.setMethodCallHandler { [weak self] call, result in
        if call.method == "getApnsDiag" {
          result(self?.apnsDiag ?? "self_nil")
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }

    // Explicitly request APNs registration in case Firebase swizzling missed it.
    application.registerForRemoteNotifications()

    return result
  }

  // APNs registration succeeded — forward token to Firebase explicitly.
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Messaging.messaging().apnsToken = deviceToken
    let hex = deviceToken.map { String(format: "%02x", $0) }.joined()
    apnsDiag = "apns_ok:\(hex.prefix(16))"
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  // APNs registration failed — capture the error reason.
  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    apnsDiag = "apns_fail:\(error.localizedDescription)"
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }
}
