import Bindings
import XCTestDynamicOverlay

public struct CMixPauseNodeRegistrations {
  public var run: (Int) throws -> Void

  public func callAsFunction(timeoutMS: Int) throws -> Void {
    try run(timeoutMS)
  }
}

extension CMixPauseNodeRegistrations {
  public static func live(_ bindingsCMix: BindingsCmix) -> CMixPauseNodeRegistrations {
    CMixPauseNodeRegistrations(
      run: bindingsCMix.pauseNodeRegistrations
    )
  }
}

extension CMixPauseNodeRegistrations {
  public static let unimplemented = CMixPauseNodeRegistrations(
    run: XCTUnimplemented("\(Self.self)")
  )
}
