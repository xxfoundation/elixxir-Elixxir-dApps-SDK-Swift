import CustomDump
import XCTest
@testable import ElixxirDAppsSDK

final class SingleUseCallbackReportTests: XCTestCase {
  func testCoding() throws {
    let rounds: [Int] = [1, 5, 9]
    let payloadB64 = "rSuPD35ELWwm5KTR9ViKIz/r1YGRgXIl5792SF8o8piZzN6sT4Liq4rUU/nfOPvQEjbfWNh/NYxdJ72VctDnWw=="
    let partnerB64 = "emV6aW1hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD"
    let ephId: Int64 = 1_655_533
    let receptionIdB64 = "emV6aW1hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD"
    let jsonString = """
    {
      "Rounds": [\(rounds.map { "\($0)" }.joined(separator: ", "))],
      "Payload": "\(payloadB64)",
      "Partner": "\(partnerB64)",
      "EphID": \(ephId),
      "ReceptionID": "\(receptionIdB64)"
    }
    """
    let jsonData = jsonString.data(using: .utf8)!
    let model = try SingleUseCallbackReport.decode(jsonData)

    XCTAssertNoDifference(model, SingleUseCallbackReport(
      rounds: rounds,
      payload: Data(base64Encoded: payloadB64)!,
      partner: Data(base64Encoded: partnerB64)!,
      ephId: ephId,
      receptionId: Data(base64Encoded: receptionIdB64)!
    ))

    let encodedModel = try model.encode()
    let decodedModel = try SingleUseCallbackReport.decode(encodedModel)

    XCTAssertNoDifference(decodedModel, model)
  }
}
