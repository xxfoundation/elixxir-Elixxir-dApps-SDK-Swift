import Bindings
import XCTestDynamicOverlay

public struct GetNotificationsReport {
  public var run: (Int, String, MessageServiceList) throws -> NotificationReport

  public func callAsFunction(
    e2eId: Int,
    notificationCSV: String,
    services: MessageServiceList
  ) throws -> NotificationReport {
    try run(e2eId, notificationCSV, services)
  }
}

extension GetNotificationsReport {
  public static func live() -> GetNotificationsReport {
    GetNotificationsReport { e2eId, notificationCSV, services in
      var error: NSError?
      let result = BindingsGetNotificationsReport(
        e2eId,
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
      return try NotificationReport.decode(result)
    }
  }
}

extension GetNotificationsReport {
  public static let unimplemented = GetNotificationsReport(
    run: XCTUnimplemented("\(Self.self)")
  )
}
