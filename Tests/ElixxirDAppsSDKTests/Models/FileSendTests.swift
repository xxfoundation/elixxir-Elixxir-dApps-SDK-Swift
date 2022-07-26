import CustomDump
import XCTest
@testable import ElixxirDAppsSDK

final class FileSendTests: XCTestCase {
  func testCoding() throws {
    let name = "testfile.txt"
    let type = "text file"
    let previewB64 = "aXQncyBtZSBhIHByZXZpZXc="
    let contentsB64 = "VGhpcyBpcyB0aGUgZnVsbCBjb250ZW50cyBvZiB0aGUgZmlsZSBpbiBieXRlcw=="
    let jsonString = """
    {
      "Name": "\(name)",
      "Type": "\(type)",
      "Preview": "\(previewB64)",
      "Contents": "\(contentsB64)"
    }
    """
    let jsonData = jsonString.data(using: .utf8)!

    let fileSend = try FileSend.decode(jsonData)

    XCTAssertNoDifference(fileSend, FileSend(
      name: name,
      type: type,
      preview: Data(base64Encoded: previewB64)!,
      contents: Data(base64Encoded: contentsB64)!
    ))

    let encodedFileSend = try fileSend.encode()
    let decodedFileSend = try FileSend.decode(encodedFileSend)

    XCTAssertNoDifference(decodedFileSend, fileSend)
  }
}
