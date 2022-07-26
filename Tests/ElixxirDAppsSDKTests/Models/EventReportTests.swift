import CustomDump
import XCTest
@testable import ElixxirDAppsSDK

final class EventReportTests: XCTestCase {
  func testCoding() throws {
    let priority: Int = 1
    let category = "Test Events"
    let eventType = "Ping"
    let details = "This is an example of an event report"
    let jsonString = """
    {
      "Priority": \(priority),
      "Category": "\(category)",
      "EventType": "\(eventType)",
      "Details": "\(details)"
    }
    """
    let jsonData = jsonString.data(using: .utf8)!
    let report = try EventReport.decode(jsonData)

    XCTAssertNoDifference(report, EventReport(
      priority: priority,
      category: category,
      eventType: eventType,
      details: details
    ))

    let encodedReport = try report.encode()
    let decodedReport = try EventReport.decode(encodedReport)

    XCTAssertNoDifference(decodedReport, report)
  }
}
