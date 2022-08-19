import Bindings
import XCTestDynamicOverlay

public struct GetVersion {
  public var run: () -> String

  public func callAsFunction() -> String {
    run()
  }
}

extension GetVersion {
  public static let live = GetVersion(
    run: BindingsGetVersion
  )
}

extension GetVersion {
  public static let unimplemented = GetVersion(
    run: XCTUnimplemented("\(Self.self)")
  )
}
