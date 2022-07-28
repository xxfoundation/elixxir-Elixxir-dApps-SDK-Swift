import Bindings
import XCTestDynamicOverlay

public struct ConnectionRegisterListener {
  public var run: (Int, Listener) throws -> Void

  public func callAsFunction(
    messageType: Int,
    listener: Listener
  ) throws {
    try run(messageType, listener)
  }
}

extension ConnectionRegisterListener {
  public static func live(_ bindingsConnection: BindingsConnection) -> ConnectionRegisterListener {
    ConnectionRegisterListener { messageType, listener in
      try bindingsConnection.registerListener(
        messageType,
        newListener: listener.makeBindingsListener()
      )
    }
  }

  public static func live(_ bindingsConnection: BindingsAuthenticatedConnection) -> ConnectionRegisterListener {
    ConnectionRegisterListener { messageType, listener in
      try bindingsConnection.registerListener(
        messageType,
        newListener: listener.makeBindingsListener()
      )
    }
  }
}

extension ConnectionRegisterListener {
  public static let unimplemented = ConnectionRegisterListener(
    run: XCTUnimplemented("\(Self.self)")
  )
}
