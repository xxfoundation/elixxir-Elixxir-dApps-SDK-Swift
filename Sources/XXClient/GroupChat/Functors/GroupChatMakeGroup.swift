import Bindings
import XCTestDynamicOverlay

public struct GroupChatMakeGroup {
  public var run: ([Data], Data?, Data?) throws -> GroupReport

  public func callAsFunction(
    membership: [Data],
    message: Data?,
    name: Data?
  ) throws -> GroupReport {
    try run(membership, message, name)
  }
}

extension GroupChatMakeGroup {
  public static func live(_ bindingsGroupChat: BindingsGroupChat) -> GroupChatMakeGroup {
    GroupChatMakeGroup { membership, message, name in
      let reportData = try bindingsGroupChat.makeGroup(
        try JSONEncoder().encode(membership),
        message: message,
        name: name
      )
      return try GroupReport.decode(reportData)
    }
  }
}

extension GroupChatMakeGroup {
  public static let unimplemented = GroupChatMakeGroup(
    run: XCTUnimplemented("\(Self.self)")
  )
}
