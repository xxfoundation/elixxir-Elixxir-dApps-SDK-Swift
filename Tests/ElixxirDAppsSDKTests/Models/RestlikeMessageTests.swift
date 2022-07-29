import CustomDump
import XCTest
@testable import ElixxirDAppsSDK

final class RestlikeMessageTests: XCTestCase {
  func testCoding() throws {
    let version: Int = 1
    let headersB64 = "Y29udGVudHM6YXBwbGljYXRpb24vanNvbg=="
    let contentB64 = "VGhpcyBpcyBhIHJlc3RsaWtlIG1lc3NhZ2U="
    let method: Int = 2
    let uri = "xx://CmixRestlike/rest"
    let error = ""
    let jsonString = """
    {
      "Version": \(version),
      "Headers": "\(headersB64)",
      "Content": "\(contentB64)",
      "Method": \(method),
      "URI": "\(uri)",
      "Error": "\(error)"
    }
    """
    let jsonData = jsonString.data(using: .utf8)!
    let model = try RestlikeMessage.decode(jsonData)

    XCTAssertNoDifference(model, RestlikeMessage(
      version: version,
      headers: Data(base64Encoded: headersB64)!,
      content: Data(base64Encoded: contentB64)!,
      method: method,
      uri: uri,
      error: error
    ))

    let encodedModel = try model.encode()
    let decodedModel = try RestlikeMessage.decode(encodedModel)

    XCTAssertNoDifference(decodedModel, model)
  }
}
