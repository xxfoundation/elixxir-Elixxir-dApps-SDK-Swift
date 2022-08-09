import Bindings
import XCTestDynamicOverlay

public struct CMixWaitForRoundResult {
  public var run: (Data, Int, MessageDeliveryCallback) throws -> Void

  public func callAsFunction(
    roundList: Data,
    timeoutMS: Int,
    callback: MessageDeliveryCallback
  ) throws {
    try run(roundList, timeoutMS, callback)
  }
}

extension CMixWaitForRoundResult {
  public static func live(_ bindingsCMix: BindingsCmix) -> CMixWaitForRoundResult {
    CMixWaitForRoundResult { roundList, timeoutMS, callback in
      try bindingsCMix.wait(
        forRoundResult: roundList,
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
