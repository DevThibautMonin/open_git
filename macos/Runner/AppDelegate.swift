import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
    
    override func applicationSupportsSecureRestorableState(
      _ app: NSApplication
    ) -> Bool {
      return true
    }

  override func applicationDidFinishLaunching(_ notification: Notification) {
    let controller = mainFlutterWindow!.contentViewController as! FlutterViewController

    let channel = FlutterMethodChannel(
      name: "opengit.security_scoped",
      binaryMessenger: controller.engine.binaryMessenger
    )

    channel.setMethodCallHandler { call, result in
      switch call.method {

      case "createBookmark":
        guard let path = call.arguments as? String else {
          result(FlutterError(code: "ARG", message: "Missing path", details: nil))
          return
        }

        let url = URL(fileURLWithPath: path)
        do {
          let bookmark = try url.bookmarkData(
            options: .withSecurityScope,
            includingResourceValuesForKeys: nil,
            relativeTo: nil
          )
          result(bookmark)
        } catch {
          result(FlutterError(code: "BOOKMARK", message: error.localizedDescription, details: nil))
        }

      case "resolveBookmark":
        guard let data = call.arguments as? FlutterStandardTypedData else {
          result(nil)
          return
        }

        var stale = false
        do {
          let url = try URL(
            resolvingBookmarkData: data.data,
            options: [.withSecurityScope],
            relativeTo: nil,
            bookmarkDataIsStale: &stale
          )

          _ = url.startAccessingSecurityScopedResource()
          result(url.path)
        } catch {
          result(FlutterError(code: "RESOLVE", message: error.localizedDescription, details: nil))
        }

      case "stopAccess":
        guard let path = call.arguments as? String else {
          result(nil)
          return
        }
        let url = URL(fileURLWithPath: path)
        url.stopAccessingSecurityScopedResource()
        result(nil)

      default:
        result(FlutterMethodNotImplemented)
      }
    }

    super.applicationDidFinishLaunching(notification)
  }
}
