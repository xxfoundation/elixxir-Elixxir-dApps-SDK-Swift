import Bindings
import XCTestDynamicOverlay

public struct GroupChatJoinGroup {
  public var run: (Data) throws -> Void

  public func callAsFunction(serializedGroupData: Data) throws {
    try run(serializedGroupData)
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
