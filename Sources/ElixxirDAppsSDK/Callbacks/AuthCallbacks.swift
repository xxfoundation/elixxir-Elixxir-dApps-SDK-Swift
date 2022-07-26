import Bindings
import XCTestDynamicOverlay

public struct AuthCallbacks {
  public enum Callback: Equatable {
    case confirm(contact: Data, receptionId: Data, ephemeralId: Int64, roundId: Int64)
    case request(contact: Data, receptionId: Data, ephemeralId: Int64, roundId: Int64)
    case reset(contact: Data, receptionId: Data, ephemeralId: Int64, roundId: Int64)
  }

  public init(handle: @escaping (Callback) -> Void) {
    self.handle = handle
  }

  public var handle: (Callback) -> Void
}

extension AuthCallbacks {
  public static let unimplemented = AuthCallbacks(
    handle: XCTUnimplemented("\(Self.self)")
  )
}

extension AuthCallbacks {
  func makeBindingsAuthCallbacks() -> BindingsAuthCallbacksProtocol {
    class Handler: NSObject, BindingsAuthCallbacksProtocol {
      init(_ callbacks: AuthCallbacks) {
        self.callbacks = callbacks
      }

      let callbacks: AuthCallbacks

      func confirm(_ contact: Data?, receptionId: Data?, ephemeralId: Int64, roundId: Int64) {
        guard let contact = contact else {
          fatalError("BindingsAuthCallbacks.confirm received `nil` contact")
        }
        guard let receptionId = receptionId else {
          fatalError("BindingsAuthCallbacks.confirm received `nil` receptionId")
        }
        callbacks.handle(.confirm(
          contact: contact,
          receptionId: receptionId,
          ephemeralId: ephemeralId,
          roundId: roundId
        ))
      }

      func request(_ contact: Data?, receptionId: Data?, ephemeralId: Int64, roundId: Int64) {
        guard let contact = contact else {
          fatalError("BindingsAuthCallbacks.request received `nil` contact")
        }
        guard let receptionId = receptionId else {
          fatalError("BindingsAuthCallbacks.request received `nil` receptionId")
        }
        callbacks.handle(.request(
          contact: contact,
          receptionId: receptionId,
          ephemeralId: ephemeralId,
          roundId: roundId
        ))
      }

      func reset(_ contact: Data?, receptionId: Data?, ephemeralId: Int64, roundId: Int64) {
        guard let contact = contact else {
          fatalError("BindingsAuthCallbacks.reset received `nil` contact")
        }
        guard let receptionId = receptionId else {
          fatalError("BindingsAuthCallbacks.reset received `nil` receptionId")
        }
        callbacks.handle(.reset(
          contact: contact,
          receptionId: receptionId,
          ephemeralId: ephemeralId,
          roundId: roundId
        ))
      }
    }

    return Handler(self)
  }
}
