import Bindings
import XCTestDynamicOverlay

public struct CMixWaitForRoundResult {
  public var run: (E2ESendReport, Int, MessageDeliveryCallback) throws -> Void

  public func callAsFunction(
    report: E2ESendReport,
    timeoutMS: Int,
    callback: MessageDeliveryCallback
  ) throws {
    try run(report, timeoutMS, callback)
  }
}

extension CMixWaitForRoundResult {
  public static func live(_ bindingsCMix: BindingsCmix) -> CMixWaitForRoundResult {
    CMixWaitForRoundResult { report, timeoutMS, callback in
      try bindingsCMix.wait(
        forRoundResult: try report.encode(),
        mdc: callback.makeBindingsMessageDeliveryCallback(),
        timeoutMS: timeoutMS
      )
    }
  }
}

extension CMixWaitForRoundResult {
  public static let unimplemented = CMixWaitForRoundResult(
    run: XCTUnimplemented("\(Self.self)")
  )
}
