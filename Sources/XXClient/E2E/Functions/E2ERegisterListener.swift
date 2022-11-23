import Bindings
import XCTestDynamicOverlay

public struct E2ERegisterListener {
  public var run: (Data?, Int, Listener) throws -> Void

  public func callAsFunction(
    senderId: Data?,
    messageType: Int,
    callback: Listener
  ) throws {
    try run(senderId, messageType, callback)
  }
}

extension E2ERegisterListener {
  public static func live(_ bindingsE2E: BindingsE2e) -> E2ERegisterListener {
    E2ERegisterListener { senderId, messageType, callback in
      try bindingsE2E.registerListener(
        senderId ?? Data([UInt8](repeating: 0, count: 33)),
        messageType: messageType,
        newListener: callback.makeBindingsListener()
      )
    }
  }
}

extension E2ERegisterListener {
  public static let unimplemented = E2ERegisterListener(
    run: XCTUnimplemented("\(Self.self)")
  )
}
