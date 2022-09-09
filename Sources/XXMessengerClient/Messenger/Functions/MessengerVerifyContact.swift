import XCTestDynamicOverlay
import XXClient

public struct MessengerVerifyContact {
  public var run: (Contact) throws -> Bool

  public func callAsFunction(_ contact: Contact) throws -> Bool {
    try run(contact)
  }
}

extension MessengerVerifyContact {
  public static func live(_ env: MessengerEnvironment) -> MessengerVerifyContact {
    MessengerVerifyContact { contact in
      // TODO:
      return false
    }
  }
}

extension MessengerVerifyContact {
  public static let unimplemented = MessengerVerifyContact(
    run: XCTUnimplemented("\(Self.self)")
  )
}
