import Bindings
import XCTestDynamicOverlay

public struct GroupChatLeaveGroup {
  public var run: (Data) throws -> Void

  public func callAsFunction(groupId: Data) throws {
    try run(groupId)
  }
}

extension GroupChatLeaveGroup {
  public static func live(_ bindingsGroupChat: BindingsGroupChat) -> GroupChatLeaveGroup {
    GroupChatLeaveGroup(run: bindingsGroupChat.leaveGroup)
  }
}

extension GroupChatLeaveGroup {
  public static let unimplemented = GroupChatLeaveGroup(
    run: XCTUnimplemented("\(Self.self)")
  )
}
