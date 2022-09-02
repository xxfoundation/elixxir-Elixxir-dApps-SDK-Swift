import CustomDump
import XCTest
@testable import XXClient

final class MessageServiceTests: XCTestCase {
  func testCoding() throws {
    let identifierB64 = "AQID"
    let tag = "TestTag 2"
    let metadataB64 = "BAUG"
    let jsonString = """
    {
     "Identifier": "\(identifierB64)",
     "Tag": "\(tag)",
     "Metadata": "\(metadataB64)"
    }
    """
    let jsonData = jsonString.data(using: .utf8)!
    let model = try MessageService.decode(jsonData)

    XCTAssertNoDifference(model, MessageService(
      identifier: Data(base64Encoded: identifierB64)!,
      tag: tag,
      metadata: Data(base64Encoded: metadataB64)!
    ))

    let encodedModel = try model.encode()
    let decodedModel = try MessageService.decode(encodedModel)

    XCTAssertNoDifference(decodedModel, model)
  }

  func testCodingArray() throws {
    let models = [
      MessageService(
        identifier: "service1-id".data(using: .utf8)!,
        tag: "service1-tag",
        metadata: "service1-metadata".data(using: .utf8)!
      ),
      MessageService(
        identifier: "service2-id".data(using: .utf8)!,
        tag: "service2-tag",
        metadata: "service2-metadata".data(using: .utf8)!
      ),
      MessageService(
        identifier: "service3-id".data(using: .utf8)!,
        tag: "service3-tag",
        metadata: "service3-metadata".data(using: .utf8)!
      ),
    ]

    let encodedModels = try models.encode()
    let decodedModels = try [MessageService].decode(encodedModels)

    XCTAssertNoDifference(models, decodedModels)
  }
}
