import XCTest
import XXClient
@testable import XXMessengerClient
import CustomDump

final class AuthCallbacksRegistryTests: XCTestCase {
  func testRegistry() {
    var firstAuthCallbacksDidHandle: [AuthCallbacks.Callback] = []
    var secondAuthCallbacksDidHandle: [AuthCallbacks.Callback] = []

    let firstAuthCallbacks = AuthCallbacks { callback in
      firstAuthCallbacksDidHandle.append(callback)
    }
    let secondAuthCallbacks = AuthCallbacks { callback in
      secondAuthCallbacksDidHandle.append(callback)
    }
    let messengerAuthCallbacks: AuthCallbacksRegistry = .live()
    let registeredAuthCallbacks = messengerAuthCallbacks.registered()
    let firstAuthCallbacksCancellable = messengerAuthCallbacks.register(firstAuthCallbacks)
    let secondAuthCallbacksCancellable = messengerAuthCallbacks.register(secondAuthCallbacks)

    let firstCallback = [AuthCallbacks.Callback].stubs[0]
    registeredAuthCallbacks.handle(firstCallback)

    XCTAssertNoDifference(firstAuthCallbacksDidHandle, [firstCallback])
    XCTAssertNoDifference(secondAuthCallbacksDidHandle, [firstCallback])

    firstAuthCallbacksCancellable.cancel()
    let secondCallback = [AuthCallbacks.Callback].stubs[1]
    registeredAuthCallbacks.handle(secondCallback)

    XCTAssertNoDifference(firstAuthCallbacksDidHandle, [firstCallback])
    XCTAssertNoDifference(secondAuthCallbacksDidHandle, [firstCallback, secondCallback])

    secondAuthCallbacksCancellable.cancel()

    let thirdCallback = [AuthCallbacks.Callback].stubs[2]
    registeredAuthCallbacks.handle(thirdCallback)

    XCTAssertNoDifference(firstAuthCallbacksDidHandle, [firstCallback])
    XCTAssertNoDifference(secondAuthCallbacksDidHandle, [firstCallback, secondCallback])
  }
}
