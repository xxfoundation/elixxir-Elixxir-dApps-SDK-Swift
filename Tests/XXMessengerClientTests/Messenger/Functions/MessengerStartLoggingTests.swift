import CustomDump
import XCTest
import XXClient
@testable import XXMessengerClient

final class MessengerStartLoggingTests: XCTestCase {
  func testStartLogging() {
    var registeredLogWriters: [LogWriter] = []
    var logs: [MessengerLogger.Log] = []

    var env: MessengerEnvironment = .unimplemented
    env.registerLogWriter.run = { writer in
      registeredLogWriters.append(writer)
    }
    env.logger.run = { log, _, _, _ in
      logs.append(log)
    }
    let start: MessengerStartLogging = .live(env)

    start()

    XCTAssertNoDifference(registeredLogWriters.count, 1)

    registeredLogWriters.first?.handle("DEBUG Hello, World!")

    XCTAssertNoDifference(logs, [
      .init(level: .debug, message: "Hello, World!"),
    ])
  }
}
