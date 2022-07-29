import CustomDump
import XCTest
@testable import ElixxirDAppsSDK

final class BackupReportTests: XCTestCase {
  func testCoding() throws {
    let idsB64 = "WyJPRHRRTTA4ZERpV3lXaE0wWUhjanRHWnZQcHRSa1JOZ1pHR2FkTG10dE9BRCJd"
    let paramsB64 = "cGFyYW1z"
    let jsonString = """
    {
      "BackupIdListJson": "\(idsB64)",
      "BackupParams": "\(paramsB64)"
    }
    """
    let jsonData = jsonString.data(using: .utf8)!
    let model = try BackupReport.decode(jsonData)

    XCTAssertNoDifference(model, BackupReport(
      ids: Data(base64Encoded: idsB64)!,
      params: Data(base64Encoded: paramsB64)!
    ))

    let encodedModel = try model.encode()
    let decodedModel = try BackupReport.decode(encodedModel)

    XCTAssertNoDifference(decodedModel, model)
  }
}
