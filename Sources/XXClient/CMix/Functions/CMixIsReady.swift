import Bindings
import XCTestDynamicOverlay

public struct CMixIsReady {
  public var run: (Double) throws -> IsReadyInfo

  public func callAsFunction(percent: Double) throws -> IsReadyInfo {
    try run(percent)
  }
}

extension CMixIsReady {
  public static func live(_ bindingsCMix: BindingsCmix) -> CMixIsReady {
    CMixIsReady { percent in
      try IsReadyInfo.decode(try bindingsCMix.isReady(percent))
    }
  }
}

extension CMixIsReady {
  public static let unimplemented = CMixIsReady(
    run: XCTUnimplemented("\(Self.self)")
  )
}
