import Bindings
import XCTestDynamicOverlay

public struct CMixWaitForMessageDelivery {
  public var run: (E2ESendReport, Int, MessageDeliveryCallback) throws -> Void

  public func callAsFunction(
    report: E2ESendReport,
    timeoutMS: Int,
    callback: MessageDeliveryCallback
  ) throws {
    try run(report, timeoutMS, callback)
  }
}

extension CMixWaitForMessageDelivery {
  public static func live(_ bindingsCMix: BindingsCmix) -> CMixWaitForMessageDelivery {
    CMixWaitForMessageDelivery { report, timeoutMS, callback in
      try bindingsCMix.wait(
        forMessageDelivery: try report.encode(),
        mdc: callback.makeBindingsMessageDeliveryCallback(),
        timeoutMS: timeoutMS
      )
    }
  }
}

extension CMixWaitForMessageDelivery {
  public static let unimplemented = CMixWaitForMessageDelivery(
    run: XCTUnimplemented("\(Self.self)")
  )
}
