import Bindings

public struct MessageSender {
  public var send: (Int, Data) throws -> Data

  public func callAsFunction(
    messageType: Int,
    payload: Data
  ) throws -> Data {
    try send(messageType, payload)
  }
}

extension MessageSender {
  public static func live(
    bindingsConnection: BindingsConnection
  ) -> MessageSender {
    MessageSender { messageType, payload in
      try bindingsConnection.sendE2E(messageType, payload: payload)
    }
  }

  public static func live(
    bindingsAuthenticatedConnection: BindingsAuthenticatedConnection
  ) -> MessageSender {
    MessageSender { messageType, payload in
      try bindingsAuthenticatedConnection.sendE2E(messageType, payload: payload)
    }
  }
}

#if DEBUG
extension MessageSender {
  public static let failing = MessageSender { _, _ in
    struct NotImplemented: Error {}
    throw NotImplemented()
  }
}
#endif
