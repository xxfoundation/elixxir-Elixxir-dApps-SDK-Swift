import Bindings
import XCTestDynamicOverlay

public struct CMixChangeNumberOfNodeRegistrations {
  public var run: (Int, Int) throws -> Void

  public func callAsFunction(to number: Int, timeoutMS: Int) throws {
    try run(number, timeoutMS)
  }
}

extension CMixChangeNumberOfNodeRegistrations {
  public static func live(_ bindingsCMix: BindingsCmix) -> CMixChangeNumberOfNodeRegistrations {
    CMixChangeNumberOfNodeRegistrations(
      run: bindingsCMix.changeNumber(ofNodeRegistrations:timeoutMS:)
    )
  }
}

extension CMixChangeNumberOfNodeRegistrations {
  public static let unimplemented = CMixChangeNumberOfNodeRegistrations(
    run: XCTestDynamicOverlay.unimplemented("\(Self.self)")
  )
}
