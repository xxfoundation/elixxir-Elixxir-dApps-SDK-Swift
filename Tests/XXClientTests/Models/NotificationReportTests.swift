import CustomDump
import XCTest
@testable import XXClient

final class NotificationReportTests: XCTestCase {
  func testCoding() throws {
    let forMe = true
    let type = NotificationReport.ReportType.default
    let sourceB64 = "dGVzdGVyMTIzAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
    let jsonString = """
    {
      "ForMe": true,
      "Type": "\(type.rawValue)",
      "Source": "\(sourceB64)"
    }
    """
    let jsonData = jsonString.data(using: .utf8)!
    let model = try NotificationReport.decode(jsonData)

    XCTAssertNoDifference(model, NotificationReport(
      forMe: forMe,
      type: type,
      source: Data(base64Encoded: sourceB64)!
    ))

    let encodedModel = try model.encode()
    let decodedModel = try NotificationReport.decode(encodedModel)

    XCTAssertNoDifference(decodedModel, model)
  }
}
