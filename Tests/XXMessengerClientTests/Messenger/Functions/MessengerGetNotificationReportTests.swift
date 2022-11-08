import CustomDump
import XCTest
import XCTestDynamicOverlay
import XXClient
@testable import XXMessengerClient

final class MessengerGetNotificationReportTests: XCTestCase {
  func testGetReport() throws {
    let e2eId = 123
    let serviceList = MessageServiceList.stub()
    let notificationCSV = "notification-csv"
    let notificationReport = NotificationReport.stub()

    struct GetNotificationsReportParams: Equatable {
      var e2eId: Int
      var notificationCSV: String
      var serviceList: MessageServiceList
    }
    var didGetNotificationsReport: [GetNotificationsReportParams] = []

    var env: MessengerEnvironment = .unimplemented
    env.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getId.run = { e2eId }
      return e2e
    }
    env.serviceList.get = {
      serviceList
    }
    env.getNotificationsReport.run = { e2eId, notificationCSV, serviceList in
      didGetNotificationsReport.append(.init(
        e2eId: e2eId,
        notificationCSV: notificationCSV,
        serviceList: serviceList
      ))
      return notificationReport
    }
    let getReport: MessengerGetNotificationReport = .live(env)

    let report = try getReport(notificationCSV: notificationCSV)

    XCTAssertNoDifference(didGetNotificationsReport, [
      .init(
        e2eId: e2eId,
        notificationCSV: notificationCSV,
        serviceList: serviceList
      )
    ])
    XCTAssertNoDifference(report, notificationReport)
  }

  func testGetReportWhenNotConnected() {
    var env: MessengerEnvironment = .unimplemented
    env.e2e.get = { nil }
    let getReport: MessengerGetNotificationReport = .live(env)

    XCTAssertThrowsError(try getReport(notificationCSV: "")) { error in
      XCTAssertNoDifference(
        error as? MessengerGetNotificationReport.Error,
        .notConnected
      )
    }
  }

  func testGetReportWhenServiceListMissing() {
    var env: MessengerEnvironment = .unimplemented
    env.e2e.get = { .unimplemented }
    env.serviceList.get = { nil }
    let getReport: MessengerGetNotificationReport = .live(env)

    XCTAssertThrowsError(try getReport(notificationCSV: "")) { error in
      XCTAssertNoDifference(
        error as? MessengerGetNotificationReport.Error,
        .serviceListMissing
      )
    }
  }
}

extension NotificationReport {
  static func stub() -> NotificationReport {
    NotificationReport(
      forMe: .random(),
      type: ReportType.allCases.randomElement()!,
      source: "source-\(Int.random(in: 100...999))".data(using: .utf8)!
    )
  }
}
