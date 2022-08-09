import Bindings
import XCTestDynamicOverlay

public struct E2EGetUdCertFromNdf {
  public var run: () -> Data

  public func callAsFunction() -> Data {
    run()
  }
}

extension E2EGetUdCertFromNdf {
  public static func live(_ bindingsE2E: BindingsE2e) -> E2EGetUdCertFromNdf {
    E2EGetUdCertFromNdf {
      guard let data = bindingsE2E.getUdCertFromNdf() else {
        fatalError("BindingsE2e.getUdCertFromNdf returned `nil`")
      }
      return data
    }
  }
}

extension E2EGetUdCertFromNdf {
  public static let unimplemented = E2EGetUdCertFromNdf(
    run: XCTUnimplemented("\(Self.self)")
  )
}
