import CustomDump
import XCTest
@testable import ElixxirDAppsSDK

final class SingleUseResponseReportTests: XCTestCase {
  func testCoding() throws {
    let rounds: [Int] = [1, 5, 9]
    let payloadB64 = "rSuPD35ELWwm5KTR9ViKIz/r1YGRgXIl5792SF8o8piZzN6sT4Liq4rUU/nfOPvQEjbfWNh/NYxdJ72VctDnWw=="
    let receptionIdEphId: [Int] = [0, 0, 0, 0, 0, 0, 3, 89]
    let receptionIdSourceB64 = "emV6aW1hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD"
    let jsonString = """
    {
      "Rounds": [\(rounds.map { "\($0)" }.joined(separator: ", "))],
      "Payload": "\(payloadB64)",
      "ReceptionID": {
        "EphId": [\(receptionIdEphId.map { "\($0)" }.joined(separator: ", "))],
        "Source": "\(receptionIdSourceB64)"
      },
      "Err": null
    }
    """
    let jsonData = jsonString.data(using: .utf8)!
    let model = try SingleUseResponseReport.decode(jsonData)

    XCTAssertNoDifference(model, SingleUseResponseReport(
      rounds: rounds,
      payload: Data(base64Encoded: payloadB64)!,
      receptionId: .init(
        ephId: receptionIdEphId,
        source: Data(base64Encoded: receptionIdSourceB64)!
      ),
      error: nil
    ))

    let encodedModel = try model.encode()
    let decodedModel = try SingleUseResponseReport.decode(encodedModel)

    XCTAssertNoDifference(decodedModel, model)
  }

  func testDecodingReportWithError() throws {
    let rounds: [Int] = [1, 5, 9]
    let payloadB64 = "rSuPD35ELWwm5KTR9ViKIz/r1YGRgXIl5792SF8o8piZzN6sT4Liq4rUU/nfOPvQEjbfWNh/NYxdJ72VctDnWw=="
    let receptionIdEphId: [Int] = [0, 0, 0, 0, 0, 0, 3, 89]
    let receptionIdSourceB64 = "emV6aW1hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD"
    let error = "something went wrong"
    let jsonString = """
    {
      "Rounds": [\(rounds.map { "\($0)" }.joined(separator: ", "))],
      "Payload": "\(payloadB64)",
      "ReceptionID": {
        "EphId": [\(receptionIdEphId.map { "\($0)" }.joined(separator: ", "))],
        "Source": "\(receptionIdSourceB64)"
      },
      "Err": "\(error)"
    }
    """
    let jsonData = jsonString.data(using: .utf8)!
    let model = try SingleUseResponseReport.decode(jsonData)

    XCTAssertNoDifference(model, SingleUseResponseReport(
      rounds: rounds,
      payload: Data(base64Encoded: payloadB64)!,
      receptionId: .init(
        ephId: receptionIdEphId,
        source: Data(base64Encoded: receptionIdSourceB64)!
      ),
      error: error
    ))
  }
}
