import Bindings
import XCTestDynamicOverlay

public struct GroupChatNumGroups {
  public var run: () -> Int

  public func callAsFunction() -> Int {
    run()
  }
}

extension GroupChatNumGroups {
  public static func live(_ bindingsGroupChat: BindingsGroupChat) -> GroupChatNumGroups {
    GroupChatNumGroups(run: bindingsGroupChat.numGroups)
  }
}

extension GroupChatNumGroups {
  public static let unimplemented = GroupChatNumGroups(
    run: XCTUnimplemented("\(Self.self)", placeholder: 0)
  )
}
