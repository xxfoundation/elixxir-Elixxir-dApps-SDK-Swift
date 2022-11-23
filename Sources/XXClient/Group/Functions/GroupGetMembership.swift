import Bindings
import XCTestDynamicOverlay

public struct GroupGetMembership {
  public var run: () throws -> [GroupMember]

  public func callAsFunction() throws -> [GroupMember] {
    try run()
  }
}

extension GroupGetMembership {
  public static func live(_ bindingsGroup: BindingsGroup) -> GroupGetMembership {
    GroupGetMembership {
      let data = try bindingsGroup.getMembership()
      return try [GroupMember].decode(data)
    }
  }
}

extension GroupGetMembership {
  public static let unimplemented = GroupGetMembership(
    run: XCTUnimplemented("\(Self.self)")
  )
}
