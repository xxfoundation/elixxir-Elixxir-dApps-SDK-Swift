import CustomDump
import XCTest
import XXClient
@testable import XXMessengerClient

final class GroupRequestCallbacksRegistryTests: XCTestCase {
  func testRegistry() {
    var firstCallbackDidHandle: [Group] = []
    var secondCallbackDidHandle: [Group] = []

    let firstCallback = GroupRequest { group in
      firstCallbackDidHandle.append(group)
    }
    let secondCallback = GroupRequest { group in
      secondCallbackDidHandle.append(group)
    }
    let registry: GroupRequestCallbacksRegistry = .live()
    let registeredCallbacks = registry.registered()
    let firstCallbackCancellable = registry.register(firstCallback)
    let secondCallbackCancellable = registry.register(secondCallback)

    let firstGroup = Group.stub(1)
    registeredCallbacks.handle(firstGroup)

    XCTAssertNoDifference(firstCallbackDidHandle.map { $0.getId() }, [firstGroup.getId()])
    XCTAssertNoDifference(secondCallbackDidHandle.map { $0.getId() }, [firstGroup.getId()])

    firstCallbackDidHandle = []
    secondCallbackDidHandle = []
    firstCallbackCancellable.cancel()
    let secondGroup = Group.stub(2)
    registeredCallbacks.handle(secondGroup)

    XCTAssertNoDifference(firstCallbackDidHandle.map { $0.getId() }, [])
    XCTAssertNoDifference(secondCallbackDidHandle.map { $0.getId() }, [secondGroup.getId()])

    firstCallbackDidHandle = []
    secondCallbackDidHandle = []
    secondCallbackCancellable.cancel()
    let thirdGroup = Group.stub(3)
    registeredCallbacks.handle(thirdGroup)

    XCTAssertNoDifference(firstCallbackDidHandle.map { $0.getId() }, [])
    XCTAssertNoDifference(secondCallbackDidHandle.map { $0.getId() }, [])
  }
}
