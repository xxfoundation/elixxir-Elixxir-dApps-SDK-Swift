import CustomDump
import XCTest
import XXClient
@testable import XXMessengerClient

final class GroupChatProcessorRegistryTests: XCTestCase {
  func testRegistry() {
    var firstProcessorDidHandle: [GroupChatProcessor.Result] = []
    var secondProcessorDidHandle: [GroupChatProcessor.Result] = []

    let firstProcessor = GroupChatProcessor(
      name: "first",
      handle: { firstProcessorDidHandle.append($0) }
    )
    let secondProcessor = GroupChatProcessor(
      name: "second",
      handle: { secondProcessorDidHandle.append($0) }
    )
    let registry: GroupChatProcessorRegistry = .live()
    let registeredProcessors = registry.registered()
    let firstProcessorCancellable = registry.register(firstProcessor)
    let secondProcessorCancellable = registry.register(secondProcessor)

    let firstResult = GroupChatProcessor.Result.success(.stub())
    registeredProcessors.handle(firstResult)

    XCTAssertNoDifference(firstProcessorDidHandle, [firstResult])
    XCTAssertNoDifference(secondProcessorDidHandle, [firstResult])

    firstProcessorDidHandle = []
    secondProcessorDidHandle = []
    firstProcessorCancellable.cancel()
    let secondResult = GroupChatProcessor.Result.success(.stub())
    registeredProcessors.handle(secondResult)

    XCTAssertNoDifference(firstProcessorDidHandle, [])
    XCTAssertNoDifference(secondProcessorDidHandle, [secondResult])

    firstProcessorDidHandle = []
    secondProcessorDidHandle = []
    secondProcessorCancellable.cancel()
    let thirdResult = GroupChatProcessor.Result.success(.stub())
    registeredProcessors.handle(thirdResult)

    XCTAssertNoDifference(firstProcessorDidHandle, [])
    XCTAssertNoDifference(secondProcessorDidHandle, [])
  }
}
