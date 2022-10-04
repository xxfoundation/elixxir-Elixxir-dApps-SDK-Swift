import CustomDump
import XCTest
@testable import XXMessengerClient

final class LogMessageTests: XCTestCase {
  func testParsing() {
    XCTAssertNoDifference(
      LogMessage.parse("TRACE Tracing..."),
      LogMessage(level: .trace, text: "Tracing...")
    )
    XCTAssertNoDifference(
      LogMessage.parse("DEBUG Debugging..."),
      LogMessage(level: .debug, text: "Debugging...")
    )
    XCTAssertNoDifference(
      LogMessage.parse("INFO Informing..."),
      LogMessage(level: .info, text: "Informing...")
    )
    XCTAssertNoDifference(
      LogMessage.parse("WARN Warning!"),
      LogMessage(level: .warning, text: "Warning!")
    )
    XCTAssertNoDifference(
      LogMessage.parse("ERROR Failure!"),
      LogMessage(level: .error, text: "Failure!")
    )
    XCTAssertNoDifference(
      LogMessage.parse("CRITICAL Critical failure!"),
      LogMessage(level: .critical, text: "Critical failure!")
    )
    XCTAssertNoDifference(
      LogMessage.parse("FATAL Fatal failure!"),
      LogMessage(level: .critical, text: "Fatal failure!")
    )
  }

  func testParsingFallbacks() {
    XCTAssertNoDifference(
      LogMessage.parse("1234 Wrongly formatted"),
      LogMessage(level: .notice, text: "1234 Wrongly formatted")
    )
  }

  func testParsingStripsDateTime() {
    XCTAssertNoDifference(
      LogMessage.parse("INFO 2022/10/04 Informing..."),
      LogMessage(level: .info, text: "Informing...")
    )
    XCTAssertNoDifference(
      LogMessage.parse("INFO 23:36:55.755390 Informing..."),
      LogMessage(level: .info, text: "Informing...")
    )
    XCTAssertNoDifference(
      LogMessage.parse("INFO 2022/10/04 23:36:55.755390 Informing..."),
      LogMessage(level: .info, text: "Informing...")
    )
  }
}
