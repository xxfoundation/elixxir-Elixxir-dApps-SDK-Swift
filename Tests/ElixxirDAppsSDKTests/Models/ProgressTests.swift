import CustomDump
import XCTest
@testable import ElixxirDAppsSDK

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
    let progress = try Progress.decode(jsonData)

    XCTAssertNoDifference(progress, Progress(
      completed: completed,
      transmitted: transmitted,
      total: total,
      error: nil
    ))

    let encodedProgress = try progress.encode()
    let decodedProgress = try Progress.decode(encodedProgress)

    XCTAssertNoDifference(decodedProgress, progress)
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
    let progress = try Progress.decode(jsonData)

    XCTAssertNoDifference(progress, Progress(
      completed: completed,
      transmitted: transmitted,
      total: total,
      error: error
    ))
  }
}
