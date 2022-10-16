import CustomDump
import XCTest
import XXClient
@testable import XXMessengerClient

final class ReceiveFileCallbacksRegistryTests: XCTestCase {
  func testRegistry() {
    var firstCallbackDidHandle: [ReceiveFileCallback.Result] = []
    var secondCallbackDidHandle: [ReceiveFileCallback.Result] = []

    let firstCallback = ReceiveFileCallback { result in
      firstCallbackDidHandle.append(result)
    }
    let secondCallback = ReceiveFileCallback { result in
      secondCallbackDidHandle.append(result)
    }
    let callbackRegistry: ReceiveFileCallbacksRegistry = .live()
    let registeredCallbacks = callbackRegistry.registered()
    let firstCallbackCancellable = callbackRegistry.register(firstCallback)
    let secondCallbackCancellable = callbackRegistry.register(secondCallback)

    let firstResult = ReceiveFileCallback.Result.success(.stub(1))
    registeredCallbacks.handle(firstResult)

    XCTAssertNoDifference(firstCallbackDidHandle, [firstResult])
    XCTAssertNoDifference(secondCallbackDidHandle, [firstResult])

    firstCallbackCancellable.cancel()
    let secondError = NSError(domain: "test", code: 321)
    let secondResult = ReceiveFileCallback.Result.failure(secondError)
    registeredCallbacks.handle(secondResult)

    XCTAssertNoDifference(firstCallbackDidHandle, [firstResult])
    XCTAssertNoDifference(secondCallbackDidHandle, [firstResult, secondResult])

    secondCallbackCancellable.cancel()

    let thirdData = ReceiveFileCallback.Result.success(.stub(2))
    registeredCallbacks.handle(thirdData)

    XCTAssertNoDifference(firstCallbackDidHandle, [firstResult])
    XCTAssertNoDifference(secondCallbackDidHandle, [firstResult, secondResult])
  }
}
