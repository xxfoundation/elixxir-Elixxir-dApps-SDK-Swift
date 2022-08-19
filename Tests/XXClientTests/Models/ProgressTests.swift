import CustomDump
import XCTest
@testable import XXClient

final class ProgressTests: XCTestCase {
  func testCoding() throws {
    let completed = false
    let transmitted: Int = 128
    let total: Int = 2048
    let jsonString = """
    {
      "Completed": \(completed),
      "Transmitted": \(transmitted),
      "Total": \(total),
      "Err": null
    }
    """
    let jsonData = jsonString.data(using: .utf8)!
    let model = try Progress.decode(jsonData)

    XCTAssertNoDifference(model, Progress(
      completed: completed,
      transmitted: transmitted,
      total: total,
      error: nil
    ))

    let encodedModel = try model.encode()
    let decodedModel = try Progress.decode(encodedModel)

    XCTAssertNoDifference(decodedModel, model)
  }

  func testDecodingProgressWithError() throws {
    let completed = false
    let transmitted: Int = 128
    let total: Int = 2048
    let error = "something went wrong"
    let jsonString = """
    {
      "Completed": \(completed),
      "Transmitted": \(transmitted),
      "Total": \(total),
      "Err": "\(error)"
    }
    """
    let jsonData = jsonString.data(using: .utf8)!
    let model = try Progress.decode(jsonData)

    XCTAssertNoDifference(model, Progress(
      completed: completed,
      transmitted: transmitted,
      total: total,
      error: error
    ))
  }
}
