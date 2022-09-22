import XCTestDynamicOverlay

public struct MessengerIsListeningForMessages {
  public var run: () -> Bool

  public func callAsFunction() -> Bool {
    run()
  }
}

extension MessengerIsListeningForMessages {
  public static func live(_ env: MessengerEnvironment) -> MessengerIsListeningForMessages {
    MessengerIsListeningForMessages(run: env.isListeningForMessages.get)
  }
}

extension MessengerIsListeningForMessages {
  public static let unimplemented = MessengerIsListeningForMessages(
    run: XCTUnimplemented("\(Self.self)", placeholder: false)
  )
}
