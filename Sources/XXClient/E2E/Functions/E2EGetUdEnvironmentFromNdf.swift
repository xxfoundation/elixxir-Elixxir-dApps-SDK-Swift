import Bindings
import XCTestDynamicOverlay

public struct E2EGetUdEnvironmentFromNdf {
  public var run: () throws -> UDEnvironment

  public func callAsFunction() throws -> UDEnvironment {
    try run()
  }
}

extension E2EGetUdEnvironmentFromNdf {
  public static func live(_ bindingsE2E: BindingsE2e) -> E2EGetUdEnvironmentFromNdf {
    E2EGetUdEnvironmentFromNdf {
      UDEnvironment(
        address: E2EGetUdAddressFromNdf.live(bindingsE2E)(),
        cert: E2EGetUdCertFromNdf.live(bindingsE2E)(),
        contact: try E2EGetUdContactFromNdf.live(bindingsE2E)()
      )
    }
  }
}

extension E2EGetUdEnvironmentFromNdf {
  public static let unimplemented = E2EGetUdEnvironmentFromNdf(
    run: XCTUnimplemented("\(Self.self)")
  )
}
