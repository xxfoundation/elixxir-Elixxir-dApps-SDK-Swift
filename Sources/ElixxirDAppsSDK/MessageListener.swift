//import Bindings
//
//public struct MessageListener {
//  public var listen: (Int, String, @escaping (Message) -> Void) -> Void
//
//  public func callAsFunction(
//    messageType: Int,
//    listenerName: String = "MessageListener",
//    callback: @escaping (Message) -> Void
//  ) {
//    listen(messageType, listenerName, callback)
//  }
//}
//
//extension MessageListener {
//  public static func live(
//    bindingsConnection: BindingsConnection
//  ) -> MessageListener {
//    MessageListener.live(
//      register: bindingsConnection.registerListener(_:newListener:)
//    )
//  }
//
//  public static func live(
//    bindingsAuthenticatedConnection: BindingsAuthenticatedConnection
//  ) -> MessageListener {
//    MessageListener.live(
//      register: bindingsAuthenticatedConnection.registerListener(_:newListener:)
//    )
//  }
//
//  private static func live(
//    register: @escaping (Int, BindingsListenerProtocol) -> Void
//  ) -> MessageListener {
//    MessageListener { messageType, listenerName, callback in
//      register(messageType, Listener(listenerName: listenerName, onHear: callback))
//    }
//  }
//}
//
//private class Listener: NSObject, BindingsListenerProtocol {
//  init(listenerName: String, onHear: @escaping (Message) -> Void) {
//    self.listenerName = listenerName
//    self.onHear = onHear
//    super.init()
//  }
//
//  let listenerName: String
//  let onHear: (Message) -> Void
//  let decoder = JSONDecoder()
//
//  func hear(_ item: Data?) {
//    guard let item = item else {
//      fatalError("BindingsListenerProtocol.hear received `nil`")
//    }
//    do {
//      onHear(try decoder.decode(Message.self, from: item))
//    } catch {
//      fatalError("Message decoding failed with error: \(error)")
//    }
//  }
//
//  func name() -> String {
//    listenerName
//  }
//}
//
//#if DEBUG
//extension MessageListener {
//  public static let failing = MessageListener { _, _, _ in
//    fatalError("Not implemented")
//  }
//}
//#endif
