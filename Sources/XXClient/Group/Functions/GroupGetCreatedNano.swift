import Bindings
import XCTestDynamicOverlay

public struct GroupGetCreatedNano {
  public var run: () -> Int64

  public func callAsFunction() -> Int64 {
    run()
  }
}

extension GroupGetCreatedNano {
  public static func live(_ bindingsGroup: BindingsGroup) -> GroupGetCreatedNano {
    GroupGetCreatedNano(run: bindingsGroup.getCreatedNano)
  }
}

extension GroupGetCreatedNano {
  public static let unimplemented = GroupGetCreatedNano(
    run: XCTUnimplemented("\(Self.self)", placeholder: 0)
  )
}
