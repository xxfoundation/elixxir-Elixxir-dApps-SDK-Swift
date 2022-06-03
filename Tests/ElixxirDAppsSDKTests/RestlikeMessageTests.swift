import CustomDump
import XCTest
@testable import ElixxirDAppsSDK

final class RestlikeMessageTests: XCTestCase {
  func testCoding() throws {
    let jsonString = """
    {
      "Version": 1,
      "Headers": "Y29udGVudHM6YXBwbGljYXRpb24vanNvbg==",
      "Content": "VGhpcyBpcyBhIHJlc3RsaWtlIG1lc3NhZ2U=",
      "Method": 2,
      "URI": "xx://CmixRestlike/rest",
      "Error": ""
    }
    """
    let jsonData = jsonString.data(using: .utf8)!
    let decoder = JSONDecoder()
    decoder.dataDecodingStrategy = .base64
    let message = try decoder.decode(RestlikeMessage.self, from: jsonData)

    XCTAssertNoDifference(message, RestlikeMessage(
      version: 1,
      headers: Data(base64Encoded: "Y29udGVudHM6YXBwbGljYXRpb24vanNvbg==")!,
      content: Data(base64Encoded: "VGhpcyBpcyBhIHJlc3RsaWtlIG1lc3NhZ2U=")!,
      method: 2,
      uri: "xx://CmixRestlike/rest",
      error: ""
    ))

    let encoder = JSONEncoder()
    encoder.dataEncodingStrategy = .base64
    let encodedMessage = try encoder.encode(message)
    let decodedMessage = try decoder.decode(RestlikeMessage.self, from: encodedMessage)

    XCTAssertNoDifference(decodedMessage, message)
  }
}
