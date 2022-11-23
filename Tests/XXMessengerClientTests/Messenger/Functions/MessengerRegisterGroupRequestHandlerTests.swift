import XCTest
import XXClient
@testable import XXMessengerClient

final class MessengerRegisterGroupRequestHandlerTests: XCTestCase {
  func testRegister() {
    var registered: [GroupRequest] = []
    var didHandle: [Group] = []
    var didCancel = 0

    var env: MessengerEnvironment = .unimplemented
    env.groupRequests.register = { handler in
      registered.append(handler)
      return Cancellable { didCancel += 1 }
    }
    let register: MessengerRegisterGroupRequestHandler = .live(env)
    let cancellable = register(.init { group in
      didHandle.append(group)
    })

    XCTAssertEqual(registered.count, 1)

    let group = Group.stub(1)
    registered.forEach { handler in
      handler.handle(group)
    }

    XCTAssertEqual(didHandle.map { $0.getId() }, [group.getId()])

    cancellable.cancel()

    XCTAssertEqual(didCancel, 1)
  }
}
