import Bindings
import XCTestDynamicOverlay

public struct GetNotificationsReport {
  public var run: (Int, String, Data) throws -> NotificationReport

  public func callAsFunction(
    e2eId: Int,
    notificationCSV: String,
    marshaledServices: Data
  ) throws -> NotificationReport {
    try run(e2eId, notificationCSV, marshaledServices)
  }
}

extension GetNotificationsReport {
  public static func live() -> GetNotificationsReport {
    GetNotificationsReport { e2eId, notificationCSV, marshaledServices in
      var error: NSError?
      let result = BindingsGetNotificationsReport(
        e2eId,
        notificationCSV,
        marshaledServices,
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
