import Bindings
import XCTestDynamicOverlay

public struct CMixGetNodeRegistrationStatus {
  public var run: () throws -> NodeRegistrationReport

  public func callAsFunction() throws -> NodeRegistrationReport {
    try run()
  }
}

extension CMixGetNodeRegistrationStatus {
  public static func live(_ bindingsCMix: BindingsCmix) -> CMixGetNodeRegistrationStatus {
    CMixGetNodeRegistrationStatus {
      let data = try bindingsCMix.getNodeRegistrationStatus()
      return try NodeRegistrationReport.decode(data)
    }
  }
}

extension CMixGetNodeRegistrationStatus {
  public static let unimplemented = CMixGetNodeRegistrationStatus(
    run: XCTUnimplemented("\(Self.self)")
  )
}
