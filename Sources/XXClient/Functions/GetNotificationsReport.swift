import Bindings
import XCTestDynamicOverlay

public struct GetNotificationsReport {
  public var run: (String, MessageServiceList) throws -> [NotificationReport]

  public func callAsFunction(
    notificationCSV: String,
    services: MessageServiceList
  ) throws -> [NotificationReport] {
    try run(notificationCSV, services)
  }
}

extension GetNotificationsReport {
  public static let live = GetNotificationsReport { notificationCSV, services in
    var error: NSError?
    let result = BindingsGetNotificationsReport(
      notificationCSV,
      try services.encode(),
      &error
    )
    if let error = error {
      throw error
    }
    guard let result = result else {
      fatalError("BindingsGetNotificationsReport returned nil without providing error")
    }
    return try [NotificationReport].decode(result)
  }
}

extension GetNotificationsReport {
  public static let unimplemented = GetNotificationsReport(
    run: XCTUnimplemented("\(Self.self)")
  )
}
