import Bindings
import XCTestDynamicOverlay

public struct CMixIncreaseParallelNodeRegistration {
  public var run: (Int) throws -> Void

  public func callAsFunction(num: Int) throws {
    try run(num)
  }
}

extension CMixIncreaseParallelNodeRegistration {
  public static func live(_ bindingsCMix: BindingsCmix) -> CMixIncreaseParallelNodeRegistration {
    CMixIncreaseParallelNodeRegistration(
      run: bindingsCMix.increaseParallelNodeRegistration
    )
  }
}

extension CMixIncreaseParallelNodeRegistration {
  public static let unimplemented = CMixIncreaseParallelNodeRegistration(
    run: XCTestDynamicOverlay.unimplemented("\(Self.self)")
  )
}
