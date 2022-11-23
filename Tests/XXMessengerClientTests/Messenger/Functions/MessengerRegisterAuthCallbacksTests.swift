import CustomDump
import XCTest
import XXClient
@testable import XXMessengerClient

final class MessengerRegisterAuthCallbacksTests: XCTestCase {
  func testRegisterAuthCallbacks() {
    var registeredAuthCallbacks: [AuthCallbacks] = []
    var didHandleCallbacks: [AuthCallbacks.Callback] = []
    var didCancelRegisteredAuthCallbacks = 0

    var env: MessengerEnvironment = .unimplemented
    env.authCallbacks.register = { authCallbacks in
      registeredAuthCallbacks.append(authCallbacks)
      return Cancellable { didCancelRegisteredAuthCallbacks += 1 }
    }
    let registerAuthCallbacks: MessengerRegisterAuthCallbacks = .live(env)
    let cancellable = registerAuthCallbacks(AuthCallbacks { callback in
      didHandleCallbacks.append(callback)
    })

    XCTAssertEqual(registeredAuthCallbacks.count, 1)

    registeredAuthCallbacks.forEach { authCallbacks in
      [AuthCallbacks.Callback].stubs.forEach { callback in
        authCallbacks.handle(callback)
      }
    }

    XCTAssertNoDifference(didHandleCallbacks, .stubs)

    cancellable.cancel()

    XCTAssertEqual(didCancelRegisteredAuthCallbacks, 1)
  }
}
