import Bindings
import XCTestDynamicOverlay

public struct GroupChatGetGroups {
  public var run: () throws -> [Data]

  public func callAsFunction() throws -> [Data] {
    try run()
  }
}

extension GroupChatGetGroups {
  public static func live(_ bindingsGroupChat: BindingsGroupChat) -> GroupChatGetGroups {
    GroupChatGetGroups {
      let listData = try bindingsGroupChat.getGroups()
      return try JSONDecoder().decode([Data].self, from: listData)
    }
  }
}

extension GroupChatGetGroups {
  public static let unimplemented = GroupChatGetGroups(
    run: XCTUnimplemented("\(Self.self)")
  )
}
