import Bindings
import XCTestDynamicOverlay

public struct GroupGetCreatedMS {
  public var run: () -> Int64

  public func callAsFunction() -> Int64 {
    run()
  }
}

extension GroupGetCreatedMS {
  public static func live(_ bindingsGroup: BindingsGroup) -> GroupGetCreatedMS {
    GroupGetCreatedMS(run: bindingsGroup.getCreatedMS)
  }
}

extension GroupGetCreatedMS {
  public static let unimplemented = GroupGetCreatedMS(
    run: XCTUnimplemented("\(Self.self)")
  )
}
