import Bindings
import XCTestDynamicOverlay

public struct CmixGetReceptionRegistrationValidationSignature {
  public var run: () -> Data

  public func callAsFunction() -> Data {
    run()
  }
}

extension CmixGetReceptionRegistrationValidationSignature {
  public static func live(_ bindingsCmix: BindingsCmix) -> CmixGetReceptionRegistrationValidationSignature {
    CmixGetReceptionRegistrationValidationSignature {
      guard let data = bindingsCmix.getReceptionRegistrationValidationSignature() else {
        fatalError("BindingsCmix.getReceptionRegistrationValidationSignature returned `nil`")
      }
      return data
    }
  }
}

extension CmixGetReceptionRegistrationValidationSignature {
  public static let unimplemented = CmixGetReceptionRegistrationValidationSignature(
    run: XCTUnimplemented("\(Self.self)")
  )
}
