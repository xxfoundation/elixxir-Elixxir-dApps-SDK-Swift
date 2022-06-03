import Bindings

public struct RestlikeRequestSender {
  public var send: (Int, Int, Data) throws -> Data

  public func callAsFunction(
    clientId: Int,
    connectionId: Int,
    request: Data
  ) throws -> Data {
    try send(clientId, connectionId, request)
  }
}

extension RestlikeRequestSender {
  public static func live(authenticated: Bool) -> RestlikeRequestSender {
    RestlikeRequestSender { clientId, connectionId, request in
      var error: NSError?
      let response: Data?
      if authenticated {
        response = BindingsRestlikeRequestAuth(clientId, connectionId, request, &error)
      } else {
        response = BindingsRestlikeRequest(clientId, connectionId, request, &error)
      }
      if let error = error {
        throw error
      }
      guard let response = response else {
        let functionName = "BindingsRestlikeRequest\(authenticated ? "Auth" : "")"
        fatalError("\(functionName) returned `nil` without providing error")
      }
      return response
    }
  }
}

#if DEBUG
extension RestlikeRequestSender {
  public static let failing = RestlikeRequestSender { _, _, _ in
    struct NotImplemented: Error {}
    throw NotImplemented()
  }
}
#endif
