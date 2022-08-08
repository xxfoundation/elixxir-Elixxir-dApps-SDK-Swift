import Bindings
import XCTestDynamicOverlay

public struct GroupChatResendRequest {
  public var run: (Data) throws -> GroupReport

  public func callAsFunction(groupId: Data) throws -> GroupReport {
    try run(groupId)
  }
}

extension GroupChatResendRequest {
  public static func live(_ bindingsGroupChat: BindingsGroupChat) -> GroupChatResendRequest {
    GroupChatResendRequest { groupId in
      let reportData = try bindingsGroupChat.resendRequest(groupId)
      return try GroupReport.decode(reportData)
    }
  }
}

extension GroupChatResendRequest {
  public static let unimplemented = GroupChatResendRequest(
    run: XCTUnimplemented("\(Self.self)")
  )
}
