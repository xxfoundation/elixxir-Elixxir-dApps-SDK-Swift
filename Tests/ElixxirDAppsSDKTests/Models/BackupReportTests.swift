import CustomDump
import XCTest
@testable import ElixxirDAppsSDK

final class BackupReportTests: XCTestCase {
  func testCoding() throws {
    let restoredContacts: [Data] = [
      "id1".data(using: .utf8)!,
      "id2".data(using: .utf8)!,
      "id3".data(using: .utf8)!,
    ]
    let paramsB64 = "cGFyYW1z"
    let jsonString = """
    {
      "RestoredContacts": [\(restoredContacts.map { "\"\($0.base64EncodedString())\"" }.joined(separator: ", "))],
      "Params": "\(paramsB64)"
    }
    """
    let jsonData = jsonString.data(using: .utf8)!
    let model = try BackupReport.decode(jsonData)

    XCTAssertNoDifference(model, BackupReport(
      restoredContacts: restoredContacts,
      params: Data(base64Encoded: paramsB64)!
    ))

    let encodedModel = try model.encode()
    let decodedModel = try BackupReport.decode(encodedModel)

    XCTAssertNoDifference(decodedModel, model)
  }
}
