import Bindings
import XCTestDynamicOverlay

public struct GetDefaultCmixParams {
  public var run: () -> Data

  public func callAsFunction() -> Data {
    run()
  }
}

extension GetDefaultCmixParams {
  public static let live = GetDefaultCmixParams {
    guard let data = BindingsGetDefaultCMixParams() else {
      fatalError("BindingsGetDefaultCMixParams returned `nil`")
    }
    return data
  }
}

extension GetDefaultCmixParams {
  public static let unimplemented = GetDefaultCmixParams(
    run: XCTUnimplemented("\(Self.self)")
  )
}
