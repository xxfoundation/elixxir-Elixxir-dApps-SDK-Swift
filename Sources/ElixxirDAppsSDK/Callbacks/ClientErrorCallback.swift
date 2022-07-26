import Bindings
import XCTestDynamicOverlay

public struct ClientErrorCallback {
  public init(handle: @escaping (ClientError) -> Void) {
    self.handle = handle
  }

  public var handle: (ClientError) -> Void
}

extension ClientErrorCallback {
  public static let unimplemented = ClientErrorCallback(
    handle: XCTUnimplemented("\(Self.self)")
  )
}

extension ClientErrorCallback {
  func makeBindingsClientError() -> BindingsClientErrorProtocol {
    class Reporter: NSObject, BindingsClientErrorProtocol {
      init(_ callback: ClientErrorCallback) {
        self.callback = callback
      }

      let callback: ClientErrorCallback

      func report(_ source: String?, message: String?, trace: String?) {
        guard let source = source else {
          fatalError("BindingsClientError.report received `nil` source")
        }
        guard let message = message else {
          fatalError("BindingsClientError.report received `nil` message")
        }
        guard let trace = trace else {
          fatalError("BindingsClientError.report received `nil` trace")
        }
        callback.handle(ClientError(
          source: source,
          message: message,
          trace: trace
        ))
      }
    }

    return Reporter(self)
  }
}
