import XCTest
import XXClient
@testable import XXMessengerClient

final class MessengerRegisterGroupChatProcessorTests: XCTestCase {
  func testRegister() {
    var registered: [GroupChatProcessor] = []
    var didHandle: [GroupChatProcessor.Result] = []
    var didCancel = 0

    var env: MessengerEnvironment = .unimplemented
    env.groupChatProcessors.register = { processor in
      registered.append(processor)
      return Cancellable { didCancel += 1 }
    }
    let register: MessengerRegisterGroupChatProcessor = .live(env)
    let cancellable = register(.init { result in
      didHandle.append(result)
    })

    XCTAssertEqual(registered.count, 1)

    let result = GroupChatProcessor.Result.success(.stub())
    registered.forEach { processor in
      processor.handle(result)
    }

    XCTAssertEqual(didHandle, [result])

    cancellable.cancel()

    XCTAssertEqual(didCancel, 1)
  }
}
