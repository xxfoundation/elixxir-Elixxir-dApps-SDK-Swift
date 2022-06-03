import Bindings

public struct ClientErrorListener {
  public var listen: (@escaping (ClientError) -> Void) -> Void

  public func callAsFunction(callback: @escaping (ClientError) -> Void) {
    listen(callback)
  }
}

extension ClientErrorListener {
  public static func live(bindingsClient: BindingsClient) -> ClientErrorListener {
    ClientErrorListener { callback in
      let listener = Listener(onReport: callback)
      bindingsClient.registerErrorCallback(listener)
    }
  }
}

private final class Listener: NSObject, BindingsClientErrorProtocol {
  init(onReport: @escaping (ClientError) -> Void) {
    self.onReport = onReport
    super.init()
  }

  let onReport: (ClientError) -> Void

  func report(_ source: String?, message: String?, trace: String?) {
    guard let source = source else {
      fatalError("BindingsClientError.source is `nil`")
    }
    guard let message = message else {
      fatalError("BindingsClientError.message is `nil`")
    }
    guard let trace = trace else {
      fatalError("BindingsClientError.trace is `nil`")
    }
    onReport(ClientError(source: source, message: message, trace: trace))
  }
}

#if DEBUG
extension ClientErrorListener {
  public static let failing = ClientErrorListener { _ in
    fatalError("Not implemented")
  }
}
#endif
