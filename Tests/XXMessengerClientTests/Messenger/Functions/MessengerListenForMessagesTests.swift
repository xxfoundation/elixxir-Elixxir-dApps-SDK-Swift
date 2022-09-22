import CustomDump
import XCTest
import XXClient
@testable import XXMessengerClient

final class MessengerListenForMessagesTests: XCTestCase {
  func testListen() throws {
    struct RegisterListenerParams: Equatable {
      var senderId: Data?
      var messageType: Int
    }
    var didRegisterListenerWithParams: [RegisterListenerParams] = []
    var didRegisterListenerWithCallback: [Listener] = []
    var didHandleMessage: [Message] = []
    var didSetIsListeningForMessages: [Bool] = []

    var env: MessengerEnvironment = .unimplemented
    env.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.registerListener.run = { senderId, messageType, callback in
        didRegisterListenerWithParams.append(.init(senderId: senderId, messageType: messageType))
        didRegisterListenerWithCallback.append(callback)
      }
      return e2e
    }
    env.messageListeners.registered = {
      Listener { message in didHandleMessage.append(message) }
    }
    env.isListeningForMessages.set = {
      didSetIsListeningForMessages.append($0)
    }
    let listen: MessengerListenForMessages = .live(env)

    try listen()

    XCTAssertNoDifference(didRegisterListenerWithParams, [
      .init(senderId: nil, messageType: 2)
    ])
    XCTAssertNoDifference(didSetIsListeningForMessages, [true])

    let message = Message.stub(123)
    didRegisterListenerWithCallback.first?.handle(message)

    XCTAssertNoDifference(didHandleMessage, [message])
  }

  func testListenWhenNotLoggedIn() {
    var didSetIsListeningForMessages: [Bool] = []

    var env: MessengerEnvironment = .unimplemented
    env.e2e.get = { nil }
    env.isListeningForMessages.set = { didSetIsListeningForMessages.append($0) }
    let listen: MessengerListenForMessages = .live(env)

    XCTAssertThrowsError(try listen()) { error in
      XCTAssertNoDifference(error as? MessengerListenForMessages.Error, .notConnected)
    }

    XCTAssertNoDifference(didSetIsListeningForMessages, [false])
  }

  func testListenFailure() {
    struct Failure: Error, Equatable {}
    let error = Failure()

    var didSetIsListeningForMessages: [Bool] = []

    var env: MessengerEnvironment = .unimplemented
    env.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.registerListener.run = { _, _, _ in throw error }
      return e2e
    }
    env.messageListeners.registered = { Listener.unimplemented }
    env.isListeningForMessages.set = { didSetIsListeningForMessages.append($0) }
    let listen: MessengerListenForMessages = .live(env)

    XCTAssertThrowsError(try listen()) { err in
      XCTAssertNoDifference(err as? Failure, error)
    }

    XCTAssertNoDifference(didSetIsListeningForMessages, [false])
  }
}
