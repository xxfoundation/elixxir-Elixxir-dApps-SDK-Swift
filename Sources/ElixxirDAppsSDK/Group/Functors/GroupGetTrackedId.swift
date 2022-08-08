import Bindings
import XCTestDynamicOverlay

public struct GroupGetTrackedId {
  public var run: () -> Int

  public func callAsFunction() -> Int {
    run()
  }
}

extension GroupGetTrackedId {
  public static func live(_ bindingsGroup: BindingsGroup) -> GroupGetTrackedId {
    GroupGetTrackedId(run: bindingsGroup.getTrackedID)
  }
}

extension GroupGetTrackedId {
  public static let unimplemented = GroupGetTrackedId(
    run: XCTUnimplemented("\(Self.self)")
  )
}
