import Bindings

public struct MessageDeliveryWaiter {
  public enum Result: Equatable {
    case delivered(roundResults: [Int])
    case notDelivered(timedOut: Bool)
  }

  public var wait: (MessageSendReport, Int, @escaping (Result) -> Void) throws -> Void

  public func callAsFunction(
    report: MessageSendReport,
    timeoutMS: Int,
    callback: @escaping (Result) -> Void
  ) throws {
    try wait(report, timeoutMS, callback)
  }
}

extension MessageDeliveryWaiter {
  public static func live(bindingsClient: BindingsClient) -> MessageDeliveryWaiter {
    MessageDeliveryWaiter { report, timeoutMS, callback in
      let encoder = JSONEncoder()
      let reportData = try encoder.encode(report)
      try bindingsClient.wait(
        forMessageDelivery: reportData,
        mdc: Callback(onCallback: callback),
        timeoutMS: timeoutMS
      )
    }
  }
}

private final class Callback: NSObject, BindingsMessageDeliveryCallbackProtocol {
  init(onCallback: @escaping (MessageDeliveryWaiter.Result) -> Void) {
    self.onCallback = onCallback
    super.init()
  }

  let onCallback: (MessageDeliveryWaiter.Result) -> Void

  func eventCallback(_ delivered: Bool, timedOut: Bool, roundResults: Data?) {
    if delivered, !timedOut, let roundResultsData = roundResults {
      let decoder = JSONDecoder()
      do {
        let roundResults = try decoder.decode([Int].self, from: roundResultsData)
        return onCallback(.delivered(roundResults: roundResults))
      } catch {
        fatalError("BindingsMessageDeliveryCallback roundResults decoding error: \(error)")
      }
    }
    if !delivered, roundResults == nil {
      return onCallback(.notDelivered(timedOut: timedOut))
    }
    fatalError("""
      BindingsMessageDeliveryCallback received invalid parameters:
      - delivered → \(delivered)
      - timedOut → \(timedOut)
      - roundResults == nil → \(roundResults == nil)
      """)
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
