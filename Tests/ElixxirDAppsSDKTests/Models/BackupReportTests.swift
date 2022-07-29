import CustomDump
import XCTest
@testable import ElixxirDAppsSDK

final class BackupReportTests: XCTestCase {
  func testCoding() throws {
    let ids: [Data] = [
      "id1".data(using: .utf8)!,
      "id2".data(using: .utf8)!,
      "id3".data(using: .utf8)!,
    ]
    let idsB64 = try JSONEncoder().encode(ids).base64EncodedString()
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
      ids: ids,
      params: Data(base64Encoded: paramsB64)!
    ))

    let encodedModel = try model.encode()
    let decodedModel = try BackupReport.decode(encodedModel)

    XCTAssertNoDifference(decodedModel, model)
  }
}
