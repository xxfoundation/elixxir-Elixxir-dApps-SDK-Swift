import CustomDump
import XCTest
@testable import XXClient

final class SingleUseSendReportTests: XCTestCase {
  func testCoding() throws {
    let rounds: [Int] = [1, 5, 9]
    let ephId: Int64 = 1_655_533
    let receptionIdB64 = "emV6aW1hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD"
    let jsonString = """
    {
      "Rounds": [\(rounds.map { "\($0)" }.joined(separator: ", "))],
      "EphID": \(ephId),
      "ReceptionID": "\(receptionIdB64)"
    }
    """
    let jsonData = jsonString.data(using: .utf8)!
    let model = try SingleUseSendReport.decode(jsonData)

    XCTAssertNoDifference(model, SingleUseSendReport(
      rounds: rounds,
      ephId: ephId,
      receptionId: Data(base64Encoded: receptionIdB64)!
    ))

    let encodedModel = try model.encode()
    let decodedModel = try SingleUseSendReport.decode(encodedModel)

    XCTAssertNoDifference(decodedModel, model)
  }
}
