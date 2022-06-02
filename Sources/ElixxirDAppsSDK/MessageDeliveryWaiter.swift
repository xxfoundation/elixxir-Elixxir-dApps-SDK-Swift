import Bindings

public struct MessageDeliveryWaiter {
  public struct Result: Equatable {
    public init(delivered: Bool, timedOut: Bool, roundResults: Data?) {
      self.delivered = delivered
      self.timedOut = timedOut
      self.roundResults = roundResults
    }

    public var delivered: Bool
    public var timedOut: Bool
    public var roundResults: Data?
  }

  public var wait: (Data, Int, @escaping (Result) -> Void) throws -> Void

  public func callAsFunction(
    roundList: Data,
    timeoutMS: Int,
    callback: @escaping (Result) -> Void
  ) throws -> Void {
    try wait(roundList, timeoutMS, callback)
  }
}

extension MessageDeliveryWaiter {
  public static func live(bindingsClient: BindingsClient) -> MessageDeliveryWaiter {
    MessageDeliveryWaiter { roundList, timeoutMS, callback in
      try bindingsClient.wait(
        forMessageDelivery: roundList,
        mdc: Callback(onCallback: { delivered, timedOut, roundResults in
          callback(Result(delivered: delivered, timedOut: timedOut, roundResults: roundResults))
        }),
        timeoutMS: timeoutMS
      )
    }
  }
}

private final class Callback: NSObject, BindingsMessageDeliveryCallbackProtocol {
  init(onCallback: @escaping (Bool, Bool, Data?) -> Void) {
    self.onCallback = onCallback
    super.init()
  }

  let onCallback: (Bool, Bool, Data?) -> Void

  func eventCallback(_ delivered: Bool, timedOut: Bool, roundResults: Data?) {
    onCallback(delivered, timedOut, roundResults)
  }
}

#if DEBUG
extension MessageDeliveryWaiter {
  public static let failing = MessageDeliveryWaiter { _, _, _ in
    struct NotImplemented: Error {}
    throw NotImplemented()
  }
}
#endif
