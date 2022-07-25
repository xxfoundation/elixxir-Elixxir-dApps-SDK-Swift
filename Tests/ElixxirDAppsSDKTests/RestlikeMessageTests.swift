import CustomDump
import XCTest
@testable import ElixxirDAppsSDK

final class RestlikeMessageTests: XCTestCase {
  func testCoding() throws {
    let version: Int = 1
    let headersString = "Y29udGVudHM6YXBwbGljYXRpb24vanNvbg=="
    let contentString = "VGhpcyBpcyBhIHJlc3RsaWtlIG1lc3NhZ2U="
    let method: Int = 2
    let uri = "xx://CmixRestlike/rest"
    let error = ""
    let jsonString = """
    {
      "Version": \(version),
      "Headers": "\(headersString)",
      "Content": "\(contentString)",
      "Method": \(method),
      "URI": "\(uri)",
      "Error": "\(error)"
    }
    """
    let jsonData = jsonString.data(using: .utf8)!

    let message = try RestlikeMessage.decode(jsonData)

    XCTAssertNoDifference(message, RestlikeMessage(
      version: version,
      headers: Data(base64Encoded: headersString)!,
      content: Data(base64Encoded: contentString)!,
      method: method,
      uri: uri,
      error: error
    ))

    let encodedMessage = try message.encode()
    let decodedMessage = try RestlikeMessage.decode(encodedMessage)

    XCTAssertNoDifference(decodedMessage, message)
  }
}
