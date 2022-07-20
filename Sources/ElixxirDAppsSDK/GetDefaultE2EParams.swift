import Bindings
import XCTestDynamicOverlay

public struct GetDefaultE2EParams {
  public var run: () -> Data

  public func callAsFunction() -> Data {
    run()
  }
}

extension GetDefaultE2EParams {
  public static let live = GetDefaultE2EParams {
    guard let data = BindingsGetDefaultE2EParams() else {
      fatalError("BindingsGetDefaultE2EParams returned `nil`")
    }
    return data
  }
}

extension GetDefaultE2EParams {
  public static let unimplemented = GetDefaultE2EParams(
    run: XCTUnimplemented("\(Self.self)")
  )
}
