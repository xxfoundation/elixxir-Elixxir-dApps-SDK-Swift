import CustomDump
import XCTest
@testable import XXClient

final class BackupReportTests: XCTestCase {
  func testCoding() throws {
    let restoredContact1B64 = "U4x/lrFkvxuXu59LtHLon1sUhPJSCcnZND6SugndnVID"
    let restoredContact2B64 = "15tNdkKbYXoMn58NO6VbDMDWFEyIhTWEGsvgcJsHWAgD"
    let params = "test1234"
    let jsonString = """
    {
      "RestoredContacts": [
        "\(restoredContact1B64)",
        "\(restoredContact2B64)"
      ],
      "Params": "\(params)"
    }
    """
    let jsonData = jsonString.data(using: .utf8)!
    let model = try BackupReport.decode(jsonData)

    XCTAssertNoDifference(model, BackupReport(
      restoredContacts: [
        Data(base64Encoded: restoredContact1B64)!,
        Data(base64Encoded: restoredContact2B64)!,
      ],
      params: params
    ))

    let encodedModel = try model.encode()
    let decodedModel = try BackupReport.decode(encodedModel)

    XCTAssertNoDifference(decodedModel, model)
  }
}
