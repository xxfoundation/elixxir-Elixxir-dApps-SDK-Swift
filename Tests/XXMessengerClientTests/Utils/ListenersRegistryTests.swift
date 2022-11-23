import CustomDump
import XCTest
import XXClient
@testable import XXMessengerClient

final class ListenersRegistryTestsTests: XCTestCase {
  func testRegistry() {
    var firstListenerDidHandle: [Message] = []
    var secondListenerDidHandle: [Message] = []

    let firstListener = Listener { message in
      firstListenerDidHandle.append(message)
    }
    let secondListener = Listener { message in
      secondListenerDidHandle.append(message)
    }
    let listenersRegistry: ListenersRegistry = .live()
    let registeredListeners = listenersRegistry.registered()
    let firstListenerCancellable = listenersRegistry.register(firstListener)
    let secondListenerCancellable = listenersRegistry.register(secondListener)

    let firstMessage = Message.stub(1)
    registeredListeners.handle(firstMessage)

    XCTAssertNoDifference(firstListenerDidHandle, [firstMessage])
    XCTAssertNoDifference(secondListenerDidHandle, [firstMessage])

    firstListenerCancellable.cancel()
    let secondMessage = Message.stub(2)
    registeredListeners.handle(secondMessage)

    XCTAssertNoDifference(firstListenerDidHandle, [firstMessage])
    XCTAssertNoDifference(secondListenerDidHandle, [firstMessage, secondMessage])

    secondListenerCancellable.cancel()

    let thirdMessage = Message.stub(3)
    registeredListeners.handle(thirdMessage)

    XCTAssertNoDifference(firstListenerDidHandle, [firstMessage])
    XCTAssertNoDifference(secondListenerDidHandle, [firstMessage, secondMessage])
  }
}
