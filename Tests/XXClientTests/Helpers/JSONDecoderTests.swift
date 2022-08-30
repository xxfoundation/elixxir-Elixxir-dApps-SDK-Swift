import CustomDump
import XCTest
@testable import XXClient

final class JSONDecoderTests: XCTestCase {
  func testConvertingNumberToString() {
    assertConvertingNumberToString(
      input: #"{"number":1234567890,"text":"hello"}"#,
      key: "number",
      expectedOutput: #"{"number":"1234567890","text":"hello"}"#
    )

    assertConvertingNumberToString(
      input: #"{"text":"hello","number":1234567890}"#,
      key: "number",
      expectedOutput: #"{"text":"hello","number":"1234567890"}"#
    )

    assertConvertingNumberToString(
      input: #"{  "number"  :  1234567890  ,  "text"  :  "hello"  }"#,
      key: "number",
      expectedOutput: #"{  "number"  :  "1234567890"  ,  "text"  :  "hello"  }"#
    )

    assertConvertingNumberToString(
      input: #"{  "text"  :  "hello"  ,  "number"  :  1234567890  }"#,
      key: "number",
      expectedOutput: #"{  "text"  :  "hello"  ,  "number"  :  "1234567890"  }"#
    )

    assertConvertingNumberToString(
      input: """
      {
        "number": 1234567890,
        "text": "hello"
      }
      """,
      key: "number",
      expectedOutput: """
      {
        "number": "1234567890",
        "text": "hello"
      }
      """
    )

    assertConvertingNumberToString(
      input: """
      {
        "text": "hello",
        "number": 1234567890
      }
      """,
      key: "number",
      expectedOutput: """
      {
        "text": "hello",
        "number": "1234567890"
      }
      """
    )
  }
}

private func assertConvertingNumberToString(
  input: String,
  key: String,
  expectedOutput: String,
  file: StaticString = #file,
  line: UInt = #line
) {
  XCTAssertNoDifference(
    String(
      data: JSONDecoder().convertNumberToString(
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
