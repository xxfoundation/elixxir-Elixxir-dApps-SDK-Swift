import CustomDump
import XCTest
import XXClient
@testable import XXMessengerClient

final class MessengerRegisterMessageListenerTests: XCTestCase {
  func testRegisterAuthCallbacks() {
    var registeredListeners: [Listener] = []
    var didHandleMessage: [Message] = []
    var didCancelRegisteredListener = 0

    var env: MessengerEnvironment = .unimplemented
    env.messageListeners.register = { listener in
      registeredListeners.append(listener)
      return Cancellable { didCancelRegisteredListener += 1 }
    }
    let registerMessageListener: MessengerRegisterMessageListener = .live(env)
    let cancellable = registerMessageListener(Listener { message in
      didHandleMessage.append(message)
    })

    XCTAssertEqual(registeredListeners.count, 1)

    registeredListeners.forEach { listener in
      listener.handle(Message.stub(123))
    }

    XCTAssertNoDifference(didHandleMessage, [Message.stub(123)])

    cancellable.cancel()

    XCTAssertEqual(didCancelRegisteredListener, 1)
  }
}
