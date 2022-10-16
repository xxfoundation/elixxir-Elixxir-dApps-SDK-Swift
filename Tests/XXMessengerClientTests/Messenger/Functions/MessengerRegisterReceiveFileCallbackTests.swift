import CustomDump
import XCTest
import XXClient
@testable import XXMessengerClient

final class MessengerRegisterReceiveFileCallbackTests: XCTestCase {
  func testRegisterCallback() {
    var registeredCallbacks: [ReceiveFileCallback] = []
    var didHandleResult: [ReceiveFileCallback.Result] = []
    var didCancelRegisteredCallback = 0

    var env: MessengerEnvironment = .unimplemented
    env.receiveFileCallbacks.register = { callback in
      registeredCallbacks.append(callback)
      return Cancellable { didCancelRegisteredCallback += 1 }
    }
    let registerCallback: MessengerRegisterReceiveFileCallback = .live(env)
    let cancellable = registerCallback(ReceiveFileCallback { result in
      didHandleResult.append(result)
    })

    XCTAssertEqual(registeredCallbacks.count, 1)

    registeredCallbacks.forEach { callback in
      callback.handle(.success(.stub(1)))
    }

    XCTAssertNoDifference(didHandleResult, [.success(.stub(1))])

    cancellable.cancel()

    XCTAssertEqual(didCancelRegisteredCallback, 1)
  }
}
