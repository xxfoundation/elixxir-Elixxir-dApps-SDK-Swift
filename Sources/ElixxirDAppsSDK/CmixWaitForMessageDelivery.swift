import Bindings
import XCTestDynamicOverlay

public struct CmixWaitForMessageDelivery {
  public var run: (MessageSendReport, Int, MessageDeliveryCallback) throws -> Void

  public func callAsFunction(
    report: MessageSendReport,
    timeoutMS: Int,
    callback: MessageDeliveryCallback
  ) throws {
    try run(report, timeoutMS, callback)
  }
}

extension CmixWaitForMessageDelivery {
  public static func live(_ bindingsCmix: BindingsCmix) -> CmixWaitForMessageDelivery {
    CmixWaitForMessageDelivery { report, timeoutMS, callback in
      try bindingsCmix.wait(
        forMessageDelivery: try report.encode(),
        mdc: callback.makeBindingsMessageDeliveryCallback(),
        timeoutMS: timeoutMS
      )
    }
  }
}

extension CmixWaitForMessageDelivery {
  public static let unimplemented = CmixWaitForMessageDelivery(
    run: XCTUnimplemented("\(Self.self)")
  )
}
