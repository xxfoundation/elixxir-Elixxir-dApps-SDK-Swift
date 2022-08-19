import Bindings
import XCTestDynamicOverlay

public struct GroupChatGetGroup {
  public var run: (Data) throws -> Group

  public func callAsFunction(groupId: Data) throws -> Group {
    try run(groupId)
  }
}

extension GroupChatGetGroup {
  public static func live(_ bindingsGroupChat: BindingsGroupChat) -> GroupChatGetGroup {
    GroupChatGetGroup { groupId in
      .live(try bindingsGroupChat.getGroup(groupId))
    }
  }
}

extension GroupChatGetGroup {
  public static let unimplemented = GroupChatGetGroup(
    run: XCTUnimplemented("\(Self.self)")
  )
}
