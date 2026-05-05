import Flutter
import BackgroundTasks
import GoogleMaps
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private static let taskId = "com.yourname.smartcampus.announcementsync"
  private static let securityChannel = "com.smartcampus/screen_security"

  // Tracks whether the current screen requires privacy protection.
  private var secureScreenActive = false
  // The blur view added over the window when backgrounding a secure screen.
  private var privacyOverlay: UIView?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY_HERE")

    BGTaskScheduler.shared.register(
      forTaskWithIdentifier: Self.taskId,
      using: nil
    ) { task in
      self.handleAppRefresh(task: task as! BGAppRefreshTask)
    }

    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    scheduleAppRefresh()
    return result
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    FlutterMethodChannel(
      name: Self.securityChannel,
      binaryMessenger: engineBridge.pluginRegistry.registrar(forPlugin: "ScreenSecurity")!.messenger()
    ).setMethodCallHandler { [weak self] call, result in
      guard let self else { return }
      switch call.method {
      case "setSecure":
        self.secureScreenActive = true
        result(nil)
      case "clearSecure":
        self.secureScreenActive = false
        self.removePrivacyOverlay()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  // MARK: – Privacy overlay (App Switcher blur)

  override func applicationWillResignActive(_ application: UIApplication) {
    if secureScreenActive { addPrivacyOverlay() }
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    removePrivacyOverlay()
  }

  private func addPrivacyOverlay() {
    guard privacyOverlay == nil,
          let window = UIApplication.shared.windows.first else { return }
    let blur = UIBlurEffect(style: .regular)
    let overlay = UIVisualEffectView(effect: blur)
    overlay.frame = window.bounds
    overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    window.addSubview(overlay)
    privacyOverlay = overlay
  }

  private func removePrivacyOverlay() {
    privacyOverlay?.removeFromSuperview()
    privacyOverlay = nil
  }

  // MARK: – Background sync

  private func handleAppRefresh(task: BGAppRefreshTask) {
    scheduleAppRefresh()

    let engine = FlutterEngine(name: "bg_sync_engine")
    engine.run(withEntrypoint: "backgroundMain", initialRoute: nil)
    GeneratedPluginRegistrant.register(with: engine)

    let channel = FlutterMethodChannel(
      name: "com.smartcampus/background_sync",
      binaryMessenger: engine.binaryMessenger
    )

    var done = false

    task.expirationHandler = {
      guard !done else { return }
      done = true
      task.setTaskCompleted(success: false)
    }

    channel.invokeMethod("announcementSync", arguments: nil) { _ in
      guard !done else { return }
      done = true
      task.setTaskCompleted(success: true)
    }
  }

  private func scheduleAppRefresh() {
    let request = BGAppRefreshTaskRequest(identifier: Self.taskId)
    request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
    try? BGTaskScheduler.shared.submit(request)
  }
}
