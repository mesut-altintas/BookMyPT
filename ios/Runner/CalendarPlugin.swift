import EventKit
import Flutter

class CalendarPlugin: NSObject {
  private let store = EKEventStore()

  func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "com.bookmypt/calendar",
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler(handle)
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getCalendars":
      requestAccessAndGetCalendars(result: result)
    case "getEvents":
      guard let args = call.arguments as? [String: Any],
            let calendarId = args["calendarId"] as? String,
            let startMs = args["startMs"] as? Int,
            let endMs = args["endMs"] as? Int
      else {
        result(FlutterError(code: "INVALID_ARGS", message: "Geçersiz argümanlar", details: nil))
        return
      }
      requestAccessAndGetEvents(
        calendarId: calendarId,
        start: Date(timeIntervalSince1970: Double(startMs) / 1000),
        end: Date(timeIntervalSince1970: Double(endMs) / 1000),
        result: result
      )
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func requestAccessAndGetCalendars(result: @escaping FlutterResult) {
    if #available(iOS 17.0, *) {
      store.requestFullAccessToEvents { granted, _ in
        DispatchQueue.main.async {
          if granted {
            self.returnCalendars(result: result)
          } else {
            result([])
          }
        }
      }
    } else {
      store.requestAccess(to: .event) { granted, _ in
        DispatchQueue.main.async {
          if granted {
            self.returnCalendars(result: result)
          } else {
            result([])
          }
        }
      }
    }
  }

  private func returnCalendars(result: FlutterResult) {
    let calendars = store.calendars(for: .event).map { cal -> [String: Any] in
      let color = cal.cgColor.map { UIColor(cgColor: $0) } ?? UIColor.blue
      var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
      color.getRed(&r, green: &g, blue: &b, alpha: &a)
      let colorInt = (Int(a * 255) << 24) | (Int(r * 255) << 16) | (Int(g * 255) << 8) | Int(b * 255)
      return ["id": cal.calendarIdentifier, "name": cal.title, "color": colorInt]
    }
    result(calendars)
  }

  private func requestAccessAndGetEvents(
    calendarId: String,
    start: Date,
    end: Date,
    result: @escaping FlutterResult
  ) {
    if #available(iOS 17.0, *) {
      store.requestFullAccessToEvents { granted, _ in
        DispatchQueue.main.async {
          if granted {
            self.returnEvents(calendarId: calendarId, start: start, end: end, result: result)
          } else {
            result([])
          }
        }
      }
    } else {
      store.requestAccess(to: .event) { granted, _ in
        DispatchQueue.main.async {
          if granted {
            self.returnEvents(calendarId: calendarId, start: start, end: end, result: result)
          } else {
            result([])
          }
        }
      }
    }
  }

  private func returnEvents(calendarId: String, start: Date, end: Date, result: FlutterResult) {
    guard let calendar = store.calendar(withIdentifier: calendarId) else {
      result([])
      return
    }
    let predicate = store.predicateForEvents(withStart: start, end: end, calendars: [calendar])
    let events = store.events(matching: predicate).map { event -> [String: Any] in
      [
        "id": event.eventIdentifier ?? "",
        "title": event.title ?? "Etkinlik",
        "startMs": Int(event.startDate.timeIntervalSince1970 * 1000),
        "endMs": Int(event.endDate.timeIntervalSince1970 * 1000),
      ]
    }
    result(events)
  }
}
