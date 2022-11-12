import XXClient
import XCTestDynamicOverlay

public struct MessengerGetNotificationReports {
  public enum Error: Swift.Error, Equatable {
    case serviceListMissing
  }

  public var run: (String) throws -> [NotificationReport]

  public func callAsFunction(notificationCSV: String) throws -> [NotificationReport] {
    try run(notificationCSV)
  }
}

extension MessengerGetNotificationReports {
  public static func live(_ env: MessengerEnvironment) -> MessengerGetNotificationReports {
    MessengerGetNotificationReports { notificationCSV in
      guard let serviceList = env.serviceList() else {
        throw Error.serviceListMissing
      }
      return try env.getNotificationsReport(
        notificationCSV: notificationCSV,
        services: serviceList
      )
    }
  }
}

extension MessengerGetNotificationReports {
  public static let unimplemented = MessengerGetNotificationReports(
    run: XCTUnimplemented("\(Self.self)")
  )
}
