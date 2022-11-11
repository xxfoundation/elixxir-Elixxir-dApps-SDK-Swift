import XXClient
import XCTestDynamicOverlay

public struct MessengerGetNotificationReport {
  public enum Error: Swift.Error, Equatable {
    case serviceListMissing
  }

  public var run: (String) throws -> NotificationReport

  public func callAsFunction(notificationCSV: String) throws -> NotificationReport {
    try run(notificationCSV)
  }
}

extension MessengerGetNotificationReport {
  public static func live(_ env: MessengerEnvironment) -> MessengerGetNotificationReport {
    MessengerGetNotificationReport { notificationCSV in
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

extension MessengerGetNotificationReport {
  public static let unimplemented = MessengerGetNotificationReport(
    run: XCTUnimplemented("\(Self.self)")
  )
}
