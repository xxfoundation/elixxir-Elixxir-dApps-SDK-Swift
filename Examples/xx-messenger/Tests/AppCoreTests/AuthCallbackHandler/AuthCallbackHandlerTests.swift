import CustomDump
import XCTest
import XXClient
import XXMessengerClient
@testable import AppCore

final class AuthCallbackHandlerTests: XCTestCase {
  func testCallbackHandling() throws {
    struct TestState: Equatable {
      var didRegisterAuthCallbacks = 0
      var didCancelAuthCallbacks = 0
      var didHandleRequest: [Contact] = []
      var didHandleConfirm: [Contact] = []
      var didHandleReset: [Contact] = []
    }
    var registeredAuthCallbacks: [AuthCallbacks] = []
    var state = TestState()
    var expectedState = state

    var messenger: Messenger = .unimplemented
    messenger.registerAuthCallbacks.run = { callbacks in
      state.didRegisterAuthCallbacks += 1
      registeredAuthCallbacks.append(callbacks)
      return Cancellable { state.didCancelAuthCallbacks += 1 }
    }

    let handle = AuthCallbackHandler.live(
      messenger: messenger,
      handleRequest: .init { state.didHandleRequest.append($0) },
      handleConfirm: .init { state.didHandleConfirm.append($0) },
      handleReset: .init { state.didHandleReset.append($0) }
    )

    var cancellable: Any? = handle(onError: { error in
      XCTFail("Unexpected error: \(error)")
    })

    expectedState.didRegisterAuthCallbacks += 1
    XCTAssertNoDifference(state, expectedState)

    let contact1 = XXClient.Contact.unimplemented("1".data(using: .utf8)!)
    registeredAuthCallbacks.first?.handle(
      .request(contact: contact1, receptionId: Data(), ephemeralId: 0, roundId: 0)
    )

    expectedState.didHandleRequest.append(contact1)
    XCTAssertNoDifference(state, expectedState)

    let contact2 = XXClient.Contact.unimplemented("2".data(using: .utf8)!)
    registeredAuthCallbacks.first?.handle(
      .confirm(contact: contact2, receptionId: Data(), ephemeralId: 0, roundId: 0)
    )

    expectedState.didHandleConfirm.append(contact2)
    XCTAssertNoDifference(state, expectedState)

    let contact3 = XXClient.Contact.unimplemented("3".data(using: .utf8)!)
    registeredAuthCallbacks.first?.handle(
      .reset(contact: contact3, receptionId: Data(), ephemeralId: 0, roundId: 0)
    )

    expectedState.didHandleReset.append(contact3)
    XCTAssertNoDifference(state, expectedState)

    cancellable = nil

    expectedState.didCancelAuthCallbacks += 1
    XCTAssertNoDifference(state, expectedState)

    _ = cancellable
  }

  func testCallbackHandlingFailure() {
    enum Failure: Error, Equatable {
      case request
      case confirm
      case reset
    }
    var registeredAuthCallbacks: [AuthCallbacks] = []
    var errors: [Error] = []

    var messenger: Messenger = .unimplemented
    messenger.registerAuthCallbacks.run = { callbacks in
      registeredAuthCallbacks.append(callbacks)
      return Cancellable {}
    }

    let handle = AuthCallbackHandler.live(
      messenger: messenger,
      handleRequest: .init { _ in throw Failure.request },
      handleConfirm: .init { _ in throw Failure.confirm },
      handleReset: .init { _ in throw Failure.reset }
    )

    let cancellable = handle(onError: { errors.append($0) })

    registeredAuthCallbacks.first?.handle(
      .request(contact: .unimplemented(Data()), receptionId: Data(), ephemeralId: 0, roundId: 0)
    )
    registeredAuthCallbacks.first?.handle(
      .confirm(contact: .unimplemented(Data()), receptionId: Data(), ephemeralId: 0, roundId: 0)
    )
    registeredAuthCallbacks.first?.handle(
      .reset(contact: .unimplemented(Data()), receptionId: Data(), ephemeralId: 0, roundId: 0)
    )

    XCTAssertNoDifference(
      errors.map { $0 as? Failure },
      [.request, .confirm, .reset]
    )

    _ = cancellable
  }
}
