import CustomDump
import XCTest
@testable import XXClient

final class BroadcastReportTests: XCTestCase {
  func testCoding() throws {
    let rounds: [Int] = [25, 26, 29]
    let ephId: [Int] = [0, 0, 0, 0, 0, 0, 24, 61]
    let roundURL = "https://dashboard.xx.network/rounds/25?xxmessenger=true"
    let jsonString = """
    {
      "Rounds": [\(rounds.map { "\($0)" }.joined(separator: ", "))],
      "EphID": [\(ephId.map { "\($0)" }.joined(separator: ", "))],
      "RoundURL": "\(roundURL)"
    }
    """
    let jsonData = jsonString.data(using: .utf8)!
    let model = try BroadcastReport.decode(jsonData)

    XCTAssertNoDifference(model, BroadcastReport(
      rounds: rounds,
      ephId: ephId,
      roundURL: roundURL
    ))

    let encodedModel = try model.encode()
    let decodedModel = try BroadcastReport.decode(encodedModel)

    XCTAssertNoDifference(decodedModel, model)
  }
}
