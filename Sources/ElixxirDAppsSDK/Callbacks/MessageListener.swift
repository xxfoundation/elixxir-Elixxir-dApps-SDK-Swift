import Bindings
import XCTestDynamicOverlay

public struct MessageListener {
  public init(
    name: String = "MessageListener",
    handle: @escaping (Message) -> Void
  ) {
    self.name = name
    self.handle = handle
  }

  public var name: String
  public var handle: (Message) -> Void
}

extension MessageListener {
  public static let unimplemented = MessageListener(
    name: "unimplemented",
    handle: XCTUnimplemented("\(Self.self)")
  )
}

extension MessageListener {
  func makeBindingsListener() -> BindingsListenerProtocol {
    class Listener: NSObject, BindingsListenerProtocol {
      init(_ listener: MessageListener) {
        self.listener = listener
      }

      let listener: MessageListener

      func hear(_ item: Data?) {
        guard let item = item else {
          fatalError("BindingsListener.hear received `nil`")
        }
        do {
          listener.handle(try Message.decode(item))
        } catch {
          fatalError("BindingsListener.hear message decoding failed with error: \(error)")
        }
      }

      func name() -> String {
        listener.name
      }
    }

    return Listener(self)
  }
}

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
//
//#if DEBUG
//extension MessageListener {
//  public static let failing = MessageListener { _, _, _ in
//    fatalError("Not implemented")
//  }
//}
//#endif
