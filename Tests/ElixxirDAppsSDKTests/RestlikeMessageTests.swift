import CustomDump
import XCTest
@testable import ElixxirDAppsSDK

final class RestlikeMessageTests: XCTestCase {
  func testCoding() throws {
    let headers = secureRandomData(count: 32)
    let content = secureRandomData(count: 32)
    let jsonString = """
    {
      "Version": 1,
      "Headers": \(headers.jsonEncodedBase64()),
      "Content": \(content.jsonEncodedBase64()),
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
      headers: headers,
      content: content,
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
