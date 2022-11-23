import CustomDump
import XCTest
@testable import XXMessengerClient

final class MessengerLoggerTests: XCTestCase {
  func testParsingLog() {
    XCTAssertNoDifference(
      MessengerLogger.Log.parse("TRACE Tracing..."),
      MessengerLogger.Log(level: .trace, message: "Tracing...")
    )
    XCTAssertNoDifference(
      MessengerLogger.Log.parse("DEBUG Debugging..."),
      MessengerLogger.Log(level: .debug, message: "Debugging...")
    )
    XCTAssertNoDifference(
      MessengerLogger.Log.parse("INFO Informing..."),
      MessengerLogger.Log(level: .info, message: "Informing...")
    )
    XCTAssertNoDifference(
      MessengerLogger.Log.parse("WARN Warning!"),
      MessengerLogger.Log(level: .warning, message: "Warning!")
    )
    XCTAssertNoDifference(
      MessengerLogger.Log.parse("ERROR Failure!"),
      MessengerLogger.Log(level: .error, message: "Failure!")
    )
    XCTAssertNoDifference(
      MessengerLogger.Log.parse("CRITICAL Critical failure!"),
      MessengerLogger.Log(level: .critical, message: "Critical failure!")
    )
    XCTAssertNoDifference(
      MessengerLogger.Log.parse("FATAL Fatal failure!"),
      MessengerLogger.Log(level: .critical, message: "Fatal failure!")
    )
  }

  func testParsingFallbacks() {
    XCTAssertNoDifference(
      MessengerLogger.Log.parse("1234 Wrongly formatted"),
      MessengerLogger.Log(level: .notice, message: "1234 Wrongly formatted")
    )
  }

  func testParsingStripsDateTime() {
    XCTAssertNoDifference(
      MessengerLogger.Log.parse("INFO 2022/10/04 Informing..."),
      MessengerLogger.Log(level: .info, message: "Informing...")
    )
    XCTAssertNoDifference(
      MessengerLogger.Log.parse("INFO 23:36:55.755390 Informing..."),
      MessengerLogger.Log(level: .info, message: "Informing...")
    )
    XCTAssertNoDifference(
      MessengerLogger.Log.parse("INFO 2022/10/04 23:36:55.755390 Informing..."),
      MessengerLogger.Log(level: .info, message: "Informing...")
    )
  }

  func testParsingMultilineMessage() {
    XCTAssertNoDifference(
      MessengerLogger.Log.parse("""
      ERROR 2022/10/04 23:51:15.021658 First line
      Second line
      """),
      MessengerLogger.Log(level: .error, message: """
      First line
      Second line
      """)
    )
  }
}
