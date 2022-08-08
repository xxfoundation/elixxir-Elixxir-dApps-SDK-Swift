import CustomDump
import XCTest
@testable import ElixxirDAppsSDK

final class GroupReportTests: XCTestCase {
  func testCoding() throws {
    let idB64 = "EB/70R5HYEw5htZ4Hg9ondrn3+cAc/lH2G0mjQMja3w="
    let rounds: [Int] = [1, 5, 9]
    let status: Int = 123
    let jsonString = """
    {
      "Id": "\(idB64)",
      "Rounds": [\(rounds.map { "\($0)" }.joined(separator: ", "))],
      "Status": \(status)
    }
    """
    let jsonData = jsonString.data(using: .utf8)!
    let model = try GroupReport.decode(jsonData)

    XCTAssertNoDifference(model, GroupReport(
      id: Data(base64Encoded: idB64)!,
      rounds: rounds,
      status: status
    ))

    let encodedModel = try model.encode()
    let decodedModel = try GroupReport.decode(encodedModel)

    XCTAssertNoDifference(decodedModel, model)
  }
}
