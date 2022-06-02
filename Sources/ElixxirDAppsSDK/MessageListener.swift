import Bindings

public struct MessageListener {
  public var listen: (Int, String, @escaping (Data) -> Void) -> Void

  public func callAsFunction(
    messageType: Int,
    listenerName: String = "MessageListener",
    callback: @escaping (Data) -> Void
  ) {
    listen(messageType, listenerName, callback)
  }
}

extension MessageListener {
  public static func live(
    bindingsConnection: BindingsConnection
  ) -> MessageListener {
    MessageListener.live(
      register: bindingsConnection.registerListener(_:newListener:)
    )
  }

  public static func live(
    bindingsAuthenticatedConnection: BindingsAuthenticatedConnection
  ) -> MessageListener {
    MessageListener.live(
      register: bindingsAuthenticatedConnection.registerListener(_:newListener:)
    )
  }

  private static func live(
    register: @escaping (Int, BindingsListenerProtocol) -> Data?
  ) -> MessageListener {
    MessageListener { messageType, listenerName, callback in
      let listener = Listener(listenerName: listenerName, onHear: callback)
      let listenerId = register(messageType, listener)
      guard listenerId != nil else {
        fatalError("BindingsConnection.registerListener returned `nil`")
      }
    }
  }
}

private class Listener: NSObject, BindingsListenerProtocol {
  init(listenerName: String, onHear: @escaping (Data) -> Void) {
    self.listenerName = listenerName
    self.onHear = onHear
    super.init()
  }

  let listenerName: String
  let onHear: (Data) -> Void

  func hear(_ item: Data?) {
    guard let item = item else { return }
    onHear(item)
  }

  func name() -> String {
    listenerName
  }
}

#if DEBUG
extension MessageListener {
  public static let failing = MessageListener { _, _, _ in
    fatalError("Not implemented")
  }
}
#endif
