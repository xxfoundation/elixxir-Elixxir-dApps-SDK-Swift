import CustomDump
import XCTest
@testable import ElixxirDAppsSDK

final class ChannelDefTests: XCTestCase {
  func testCoding() throws {
    let name = "My broadcast channel"
    let description = "A broadcast channel for me to test things"
    let saltB64 = "gpUqW7N22sffMXsvPLE7BA=="
    let pubKeyB64 = "LS0tLS1CRUdJTiBSU0EgUFVCTElDIEtFWS0tLS0tCk1DZ0NJUUN2YkZVckJKRFpqT3Y0Y0MvUHZZdXNvQkFtUTFkb3Znb044aHRuUjA2T3F3SURBUUFCCi0tLS0tRU5EIFJTQSBQVUJMSUMgS0VZLS0tLS0="
    let jsonString = """
    {
      "Name": "\(name)",
      "Description": "\(description)",
      "Salt": "\(saltB64)",
      "PubKey": "\(pubKeyB64)"
    }
    """
    let jsonData = jsonString.data(using: .utf8)!
    let model = try ChannelDef.decode(jsonData)

    XCTAssertNoDifference(model, ChannelDef(
      name: name,
      description: description,
      salt: Data(base64Encoded: saltB64)!,
      pubKey: Data(base64Encoded: pubKeyB64)!
    ))

    let encodedModel = try model.encode()
    let decodedModel = try ChannelDef.decode(encodedModel)

    XCTAssertNoDifference(decodedModel, model)
  }
}
