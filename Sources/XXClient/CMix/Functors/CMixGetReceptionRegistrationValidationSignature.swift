import Bindings
import XCTestDynamicOverlay

public struct CMixGetReceptionRegistrationValidationSignature {
  public var run: () -> Data

  public func callAsFunction() -> Data {
    run()
  }
}

extension CMixGetReceptionRegistrationValidationSignature {
  public static func live(_ bindingsCMix: BindingsCmix) -> CMixGetReceptionRegistrationValidationSignature {
    CMixGetReceptionRegistrationValidationSignature {
      guard let data = bindingsCMix.getReceptionRegistrationValidationSignature() else {
        fatalError("BindingsCmix.getReceptionRegistrationValidationSignature returned `nil`")
      }
      return data
    }
  }
}

extension CMixGetReceptionRegistrationValidationSignature {
  public static let unimplemented = CMixGetReceptionRegistrationValidationSignature(
    run: XCTUnimplemented("\(Self.self)", placeholder: "unimplemented".data(using: .utf8)!)
  )
}
