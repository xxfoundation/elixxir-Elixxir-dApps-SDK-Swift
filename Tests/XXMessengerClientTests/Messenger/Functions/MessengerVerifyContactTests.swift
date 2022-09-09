import CustomDump
import XCTest
import XXClient
@testable import XXMessengerClient

final class MessengerVerifyContactTests: XCTestCase {
  func testVerify() throws {
    var env: MessengerEnvironment = .unimplemented
    let verify: MessengerVerifyContact = .live(env)
    let contact = Contact.unimplemented("data".data(using: .utf8)!)

    let result = try verify(contact)

    XCTAssertNoDifference(result, false)
  }
}
