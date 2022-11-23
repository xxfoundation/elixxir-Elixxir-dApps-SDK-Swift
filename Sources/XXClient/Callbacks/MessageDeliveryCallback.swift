import Bindings
import XCTestDynamicOverlay

public struct MessageDeliveryCallback {
  public enum Result: Equatable {
    case delivered(roundResults: [Int])
    case notDelivered(timedOut: Bool)
  }

  public init(handle: @escaping (Result) -> Void) {
    self.handle = handle
  }

  public var handle: (Result) -> Void
}

extension MessageDeliveryCallback {
  public static let unimplemented = MessageDeliveryCallback(
    handle: XCTUnimplemented("\(Self.self)")
  )
}

extension MessageDeliveryCallback {
  func makeBindingsMessageDeliveryCallback() -> BindingsMessageDeliveryCallbackProtocol {
    class CallbackObject: NSObject, BindingsMessageDeliveryCallbackProtocol {
      init(_ callback: MessageDeliveryCallback) {
        self.callback = callback
      }

      let callback: MessageDeliveryCallback

      func eventCallback(_ delivered: Bool, timedOut: Bool, roundResults: Data?) {
        if delivered && !timedOut {
          let roundResultsArray: [Int]
          if let data = roundResults,
             let array = try? JSONDecoder().decode([Int].self, from: data) {
            roundResultsArray = array
          } else {
            roundResultsArray = []
          }
          callback.handle(.delivered(roundResults: roundResultsArray))
          return
        }

        if !delivered {
          callback.handle(.notDelivered(timedOut: timedOut))
          return
        }

        fatalError("""
          BindingsMessageDeliveryCallback received invalid parameters:
          - delivered → \(delivered)
          - timedOut → \(timedOut)
          - roundResults → \(roundResults.map { String(data: $0, encoding: .utf8) ?? "\($0)" } ?? "nil")
          """)
      }
    }

    return CallbackObject(self)
  }
}
