import CustomDump
import XCTest
import XXClient
@testable import XXMessengerClient

final class ReceiveFileCallbacksRegistryTests: XCTestCase {
  func testRegistry() {
    var firstCallbackDidHandle: [Result<ReceivedFile, NSError>] = []
    var secondCallbackDidHandle: [Result<ReceivedFile, NSError>] = []

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

    let firstResult = Result<ReceivedFile, NSError>.success(.stub(1))
    registeredCallbacks.handle(firstResult)

    XCTAssertNoDifference(firstCallbackDidHandle, [firstResult])
    XCTAssertNoDifference(secondCallbackDidHandle, [firstResult])

    firstCallbackCancellable.cancel()
    let secondError = NSError(domain: "test", code: 321)
    let secondResult = Result<ReceivedFile, NSError>.failure(secondError)
    registeredCallbacks.handle(secondResult)

    XCTAssertNoDifference(firstCallbackDidHandle, [firstResult])
    XCTAssertNoDifference(secondCallbackDidHandle, [firstResult, secondResult])

    secondCallbackCancellable.cancel()

    let thirdData = Result<ReceivedFile, NSError>.success(.stub(2))
    registeredCallbacks.handle(thirdData)

    XCTAssertNoDifference(firstCallbackDidHandle, [firstResult])
    XCTAssertNoDifference(secondCallbackDidHandle, [firstResult, secondResult])
  }
}

private extension ReceivedFile {
  static func stub(_ id: Int) -> ReceivedFile {
    ReceivedFile(
      transferId: "transfer-id-\(id)".data(using: .utf8)!,
      senderId: "sender-id-\(id)".data(using: .utf8)!,
      preview: "preview-\(id)".data(using: .utf8)!,
      name: "name-\(id)",
      type: "type-\(id)",
      size: id
    )
  }
}
