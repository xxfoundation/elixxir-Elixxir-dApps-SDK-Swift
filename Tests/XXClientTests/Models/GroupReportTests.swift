import CustomDump
import XCTest
@testable import XXClient

final class GroupReportTests: XCTestCase {
  func testCoding() throws {
    let idB64 = "AAAAAAAAAM0AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAE"
    let rounds: [Int] = [25, 64]
    let roundURL = "https://dashboard.xx.network/rounds/25?xxmessenger=true"
    let status: Int = 1
    let jsonString = """
    {
      "Id": "\(idB64)",
      "Rounds": [\(rounds.map { "\($0)" }.joined(separator: ", "))],
      "RoundURL": "\(roundURL)",
      "Status": \(status)
    }
    """
    let jsonData = jsonString.data(using: .utf8)!
    let model = try GroupReport.decode(jsonData)

    XCTAssertNoDifference(model, GroupReport(
      id: Data(base64Encoded: idB64)!,
      rounds: rounds,
      roundURL: roundURL,
      status: status
    ))

    let encodedModel = try model.encode()
    let decodedModel = try GroupReport.decode(encodedModel)

    XCTAssertNoDifference(decodedModel, model)
  }
}
