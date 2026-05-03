import Flutter
import BackgroundTasks
import GoogleMaps
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private static let taskId = "com.yourname.smartcampus.announcementsync"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY_HERE")

    // Registration must happen before super returns
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
  }

  // MARK: – Background sync

  private func handleAppRefresh(task: BGAppRefreshTask) {
    scheduleAppRefresh() // re-schedule first — skipping this prevents future executions

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
