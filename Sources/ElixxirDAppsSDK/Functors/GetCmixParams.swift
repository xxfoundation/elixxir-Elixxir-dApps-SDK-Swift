import Bindings
import XCTestDynamicOverlay

public struct GetCmixParams {
  public var run: () -> Data

  public func callAsFunction() -> Data {
    run()
  }
}

extension GetCmixParams {
  public static let liveDefault = GetCmixParams {
    guard let data = BindingsGetDefaultCMixParams() else {
      fatalError("BindingsGetDefaultCMixParams returned `nil`")
    }
    return data
  }
}

extension GetCmixParams {
  public static let unimplemented = GetCmixParams(
    run: XCTUnimplemented("\(Self.self)")
  )
}
