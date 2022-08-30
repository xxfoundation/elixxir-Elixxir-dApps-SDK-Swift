import CustomDump
import XCTest
@testable import XXClient

final class JSONEncoderTests: XCTestCase {
  func testConvertingStringToNumber() {
    assertConvertingStringToNumber(
      input: #"{"number":"1234567890","text":"hello"}"#,
      key: "number",
      expectedOutput: #"{"number":1234567890,"text":"hello"}"#
    )

    assertConvertingStringToNumber(
      input: #"{"text":"hello","number":"1234567890"}"#,
      key: "number",
      expectedOutput: #"{"text":"hello","number":1234567890}"#
    )

    assertConvertingStringToNumber(
      input: #"{  "number"  :  "1234567890"  ,  "text"  :  "hello"  }"#,
      key: "number",
      expectedOutput: #"{  "number"  :  1234567890  ,  "text"  :  "hello"  }"#
    )

    assertConvertingStringToNumber(
      input: #"{  "text"  :  "hello"  ,  "number"  :  "1234567890"  }"#,
      key: "number",
      expectedOutput: #"{  "text"  :  "hello"  ,  "number"  :  1234567890  }"#
    )

    assertConvertingStringToNumber(
      input: """
      {
        "number": "1234567890",
        "text": "hello"
      }
      """,
      key: "number",
      expectedOutput: """
      {
        "number": 1234567890,
        "text": "hello"
      }
      """
    )

    assertConvertingStringToNumber(
      input: """
      {
        "text": "hello",
        "number": "1234567890"
      }
      """,
      key: "number",
      expectedOutput: """
      {
        "text": "hello",
        "number": 1234567890
      }
      """
    )
  }
}

private func assertConvertingStringToNumber(
  input: String,
  key: String,
  expectedOutput: String,
  file: StaticString = #file,
  line: UInt = #line
) {
  XCTAssertNoDifference(
    String(
      data: JSONEncoder().convertStringToNumber(
        in: input.data(using: .utf8)!,
        at: key
      ),
      encoding: .utf8
    )!,
    expectedOutput,
    file: file,
    line: line
  )
}
