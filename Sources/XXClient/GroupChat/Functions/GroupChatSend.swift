import Bindings
import XCTestDynamicOverlay

public struct GroupChatSend {
  public var run: (Data, Data, String?) throws -> GroupSendReport

  public func callAsFunction(
    groupId: Data,
    message: Data,
    tag: String? = nil
  ) throws -> GroupSendReport {
    try run(groupId, message, tag)
  }
}

extension GroupChatSend {
  public static func live(_ bindingsGroupChat: BindingsGroupChat) -> GroupChatSend {
    GroupChatSend { groupId, message, tag in
      let reportData = try bindingsGroupChat.send(groupId, message: message, tag: tag)
      return try GroupSendReport.decode(reportData)
    }
  }
}

extension GroupChatSend {
  public static let unimplemented = GroupChatSend(
    run: XCTUnimplemented("\(Self.self)")
  )
}
