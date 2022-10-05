import CustomDump
import XCTest
import XXClient
@testable import XXMessengerClient

final class MessengerStartLoggingTests: XCTestCase {
  func testStartLogging() {
    var registeredLogWriters: [LogWriter] = []
    var logMessages: [LogMessage] = []

    var env: MessengerEnvironment = .unimplemented
    env.registerLogWriter.run = { writer in
      registeredLogWriters.append(writer)
    }
    env.log = { message in
      logMessages.append(message)
    }
    let start: MessengerStartLogging = .live(env)

    start()

    XCTAssertNoDifference(registeredLogWriters.count, 1)

    registeredLogWriters.first?.handle("DEBUG Hello, World!")

    XCTAssertNoDifference(logMessages, [
      .init(level: .debug, text: "Hello, World!"),
    ])
  }
}
