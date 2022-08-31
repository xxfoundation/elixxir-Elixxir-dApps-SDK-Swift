import Bindings
import XCTestDynamicOverlay

public struct GetDependencies {
  public var run: () -> String

  public func callAsFunction() -> String {
    run()
  }
}

extension GetDependencies {
  public static let live = GetDependencies(run: BindingsGetDependencies)
}

extension GetDependencies {
  public static let unimplemented = GetDependencies(
    run: XCTUnimplemented("\(Self.self)", placeholder: "unimplemented")
  )
}
