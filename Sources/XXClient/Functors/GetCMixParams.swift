import Bindings
import XCTestDynamicOverlay

public struct GetCMixParams {
  public var run: () -> Data

  public func callAsFunction() -> Data {
    run()
  }
}

extension GetCMixParams {
  public static let liveDefault = GetCMixParams {
    guard let data = BindingsGetDefaultCMixParams() else {
      fatalError("BindingsGetDefaultCMixParams returned `nil`")
    }
    return data
  }
}

extension GetCMixParams {
  public static let unimplemented = GetCMixParams(
    run: XCTUnimplemented("\(Self.self)", placeholder: "unimplemented".data(using: .utf8)!)
  )
}
