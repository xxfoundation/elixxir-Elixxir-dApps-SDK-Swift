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

  func testCodingArray() throws {
    let source1B64 = "dGVzdGVyMTIzAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
    let source2B64 = "ciI1cpyUUY/UPaVeMy1zBFWbZRgiZSXhY+cVoM+fCxwD"
    let jsonString = """
    [
      {
        "ForMe": true,
        "Type": "\(NotificationReport.ReportType.default.rawValue)",
        "Source": "\(source1B64)"
      },
      {
        "ForMe": false,
        "Type": "\(NotificationReport.ReportType.request.rawValue)",
        "Source": "\(source2B64)"
      },
    ]
    """
    let jsonData = jsonString.data(using: .utf8)!
    let models = try [NotificationReport].decode(jsonData)

    XCTAssertNoDifference(models, [
      NotificationReport(
        forMe: true,
        type: .default,
        source: Data(base64Encoded: source1B64)!
      ),
      NotificationReport(
        forMe: false,
        type: .request,
        source: Data(base64Encoded: source2B64)!
      )
    ])

    let encodedModels = try models.encode()
    let decodedModels = try [NotificationReport].decode(encodedModels)

    XCTAssertNoDifference(decodedModels, models)
  }
}
