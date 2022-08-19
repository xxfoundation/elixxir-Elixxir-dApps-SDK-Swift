import Bindings
import XCTestDynamicOverlay

public struct GroupGetMembership {
  public var run: () throws -> Data

  public func callAsFunction() throws -> Data {
    try run()
  }
}

extension GroupGetMembership {
  public static func live(_ bindingsGroup: BindingsGroup) -> GroupGetMembership {
    GroupGetMembership {
      try bindingsGroup.getMembership()
    }
  }
}

extension GroupGetMembership {
  public static let unimplemented = GroupGetMembership(
    run: XCTUnimplemented("\(Self.self)")
  )
}
