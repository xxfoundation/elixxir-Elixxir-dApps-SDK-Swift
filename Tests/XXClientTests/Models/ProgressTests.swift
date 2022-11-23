import CustomDump
import XCTest
@testable import XXClient

final class ProgressTests: XCTestCase {
  func testCoding() throws {
    let transferIdB64 = "RyJcMqtI3IIM1+YMxRwCcFiOX6AGuIzS+vQaPnqXVT8="
    let completed = false
    let transmitted: Int = 128
    let total: Int = 2048
    let jsonString = """
    {
      "TransferID": "\(transferIdB64)",
      "Completed": \(completed),
      "Transmitted": \(transmitted),
      "Total": \(total)
    }
    """
    let jsonData = jsonString.data(using: .utf8)!
    let model = try Progress.decode(jsonData)

    XCTAssertNoDifference(model, Progress(
      transferId: Data(base64Encoded: transferIdB64)!,
      completed: completed,
      transmitted: transmitted,
      total: total
    ))

    let encodedModel = try model.encode()
    let decodedModel = try Progress.decode(encodedModel)

    XCTAssertNoDifference(decodedModel, model)
  }
}
