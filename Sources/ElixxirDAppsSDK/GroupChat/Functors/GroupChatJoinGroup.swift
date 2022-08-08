import Bindings
import XCTestDynamicOverlay

public struct GroupChatJoinGroup {
  public var run: (Int) throws -> Void

  public func callAsFunction(trackedGroupId: Int) throws {
    try run(trackedGroupId)
  }
}

extension GroupChatJoinGroup {
  public static func live(_ bindingsGroupChat: BindingsGroupChat) -> GroupChatJoinGroup {
    GroupChatJoinGroup(run: bindingsGroupChat.joinGroup)
  }
}

extension GroupChatJoinGroup {
  public static let unimplemented = GroupChatJoinGroup(
    run: XCTUnimplemented("\(Self.self)")
  )
}
