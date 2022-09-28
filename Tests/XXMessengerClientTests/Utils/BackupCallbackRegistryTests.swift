import CustomDump
import XCTest
import XXClient
@testable import XXMessengerClient

final class BackupCallbackRegistryTests: XCTestCase {
  func testRegistry() {
    var firstCallbackDidHandle: [Data] = []
    var secondCallbackDidHandle: [Data] = []

    let firstCallback = UpdateBackupFunc { data in
      firstCallbackDidHandle.append(data)
    }
    let secondCallback = UpdateBackupFunc { data in
      secondCallbackDidHandle.append(data)
    }
    let callbackRegistry: BackupCallbacksRegistry = .live()
    let registeredCallbacks = callbackRegistry.registered()
    let firstCallbackCancellable = callbackRegistry.register(firstCallback)
    let secondCallbackCancellable = callbackRegistry.register(secondCallback)

    let firstData = "1".data(using: .utf8)!
    registeredCallbacks.handle(firstData)

    XCTAssertNoDifference(firstCallbackDidHandle, [firstData])
    XCTAssertNoDifference(secondCallbackDidHandle, [firstData])

    firstCallbackCancellable.cancel()
    let secondData = "2".data(using: .utf8)!
    registeredCallbacks.handle(secondData)

    XCTAssertNoDifference(firstCallbackDidHandle, [firstData])
    XCTAssertNoDifference(secondCallbackDidHandle, [firstData, secondData])

    secondCallbackCancellable.cancel()

    let thirdData = "3".data(using: .utf8)!
    registeredCallbacks.handle(thirdData)

    XCTAssertNoDifference(firstCallbackDidHandle, [firstData])
    XCTAssertNoDifference(secondCallbackDidHandle, [firstData, secondData])
  }
}
