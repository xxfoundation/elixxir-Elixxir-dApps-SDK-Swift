import Bindings

public struct MessageSender {
  public var send: (Int, Data) throws -> MessageSendReport

  public func callAsFunction(
    messageType: Int,
    payload: Data
  ) throws -> MessageSendReport {
    try send(messageType, payload)
  }
}

extension MessageSender {
  public static func live(
    bindingsConnection: BindingsConnection
  ) -> MessageSender {
    MessageSender.live(sendE2E: bindingsConnection.sendE2E(_:payload:))
  }

  public static func live(
    bindingsAuthenticatedConnection: BindingsAuthenticatedConnection
  ) -> MessageSender {
    MessageSender.live(sendE2E: bindingsAuthenticatedConnection.sendE2E(_:payload:))
  }

  private static func live(
    sendE2E: @escaping (Int, Data) throws -> Data
  ) -> MessageSender {
    MessageSender { messageType, payload in
      let reportData = try sendE2E(messageType, payload)
      let decoder = JSONDecoder()
      let report = try decoder.decode(MessageSendReport.self, from: reportData)
      return report
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
