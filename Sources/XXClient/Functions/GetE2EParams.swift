import Bindings
import XCTestDynamicOverlay

public struct GetE2EParams {
  public var run: () -> Data

  public func callAsFunction() -> Data {
    run()
  }
}

extension GetE2EParams {
  public static let liveDefault = GetE2EParams {
    guard let data = BindingsGetDefaultE2EParams() else {
      fatalError("BindingsGetDefaultE2EParams returned `nil`")
    }
    return data
  }
}

extension GetE2EParams {
  public static let unimplemented = GetE2EParams(
    run: XCTUnimplemented("\(Self.self)", placeholder: "unimplemented".data(using: .utf8)!)
  )
}
