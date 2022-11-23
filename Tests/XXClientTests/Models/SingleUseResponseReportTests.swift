import CustomDump
import XCTest
@testable import XXClient

final class SingleUseResponseReportTests: XCTestCase {
  func testCoding() throws {
    let rounds: [Int] = [1, 5, 9]
    let roundURL = "https://dashboard.xx.network/rounds/25?xxmessenger=true"
    let payloadB64 = "rSuPD35ELWwm5KTR9ViKIz/r1YGRgXIl5792SF8o8piZzN6sT4Liq4rUU/nfOPvQEjbfWNh/NYxdJ72VctDnWw=="
    let ephId: Int64 = 1_655_533
    let receptionIdB64 = "emV6aW1hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD"
    let jsonString = """
    {
      "Rounds": [\(rounds.map { "\($0)" }.joined(separator: ", "))],
      "RoundURL": "\(roundURL)",
      "Payload": "\(payloadB64)",
      "EphID": \(ephId),
      "ReceptionID": "\(receptionIdB64)",
      "Err": null
    }
    """
    let jsonData = jsonString.data(using: .utf8)!
    let model = try SingleUseResponseReport.decode(jsonData)

    XCTAssertNoDifference(model, SingleUseResponseReport(
      rounds: rounds,
      roundURL: roundURL,
      payload: Data(base64Encoded: payloadB64)!,
      ephId: ephId,
      receptionId: Data(base64Encoded: receptionIdB64)!,
      error: nil
    ))

    let encodedModel = try model.encode()
    let decodedModel = try SingleUseResponseReport.decode(encodedModel)

    XCTAssertNoDifference(decodedModel, model)
  }

  func testDecodingReportWithError() throws {
    let rounds: [Int] = [1, 5, 9]
    let roundURL = "https://dashboard.xx.network/rounds/25?xxmessenger=true"
    let payloadB64 = "rSuPD35ELWwm5KTR9ViKIz/r1YGRgXIl5792SF8o8piZzN6sT4Liq4rUU/nfOPvQEjbfWNh/NYxdJ72VctDnWw=="
    let ephId: Int64 = 1_655_533
    let receptionIdB64 = "emV6aW1hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD"
    let error = "something went wrong"
    let jsonString = """
    {
      "Rounds": [\(rounds.map { "\($0)" }.joined(separator: ", "))],
      "RoundURL": "\(roundURL)",
      "Payload": "\(payloadB64)",
      "EphID": \(ephId),
      "ReceptionID": "\(receptionIdB64)",
      "Err": "\(error)"
    }
    """
    let jsonData = jsonString.data(using: .utf8)!
    let model = try SingleUseResponseReport.decode(jsonData)

    XCTAssertNoDifference(model, SingleUseResponseReport(
      rounds: rounds,
      roundURL: roundURL,
      payload: Data(base64Encoded: payloadB64)!,
      ephId: ephId,
      receptionId: Data(base64Encoded: receptionIdB64)!,
      error: error
    ))
  }
}
