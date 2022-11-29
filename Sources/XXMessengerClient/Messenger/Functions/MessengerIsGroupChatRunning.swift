import XCTestDynamicOverlay

public struct MessengerIsGroupChatRunning {
  public var run: () -> Bool

  public func callAsFunction() -> Bool {
    run()
  }
}

extension MessengerIsGroupChatRunning {
  public static func live(_ env: MessengerEnvironment) -> MessengerIsGroupChatRunning {
    MessengerIsGroupChatRunning { env.groupChat.get() != nil }
  }
}

extension MessengerIsGroupChatRunning {
  public static let unimplemented = MessengerIsGroupChatRunning(
    run: XCTestDynamicOverlay.unimplemented("\(Self.self)", placeholder: false)
  )
}
