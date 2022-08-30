import CustomDump
import XCTest
@testable import XXClient

final class JSONHelpersTests: XCTestCase {
  func testConvertingNumberToStringByKey() {
    assertConvertingJsonNumberToString(
      input: #"{"number":1234567890,"text":"hello"}"#,
      key: "number",
      expected: #"{"number":"1234567890","text":"hello"}"#
    )

    assertConvertingJsonNumberToString(
      input: #"{"text":"hello","number":1234567890}"#,
      key: "number",
      expected: #"{"text":"hello","number":"1234567890"}"#
    )

    assertConvertingJsonNumberToString(
      input: #"{  "number"  :  1234567890  ,  "text"  :  "hello"  }"#,
      key: "number",
      expected: #"{  "number"  :  "1234567890"  ,  "text"  :  "hello"  }"#
    )

    assertConvertingJsonNumberToString(
      input: #"{  "text"  :  "hello"  ,  "number"  :  1234567890  }"#,
      key: "number",
      expected: #"{  "text"  :  "hello"  ,  "number"  :  "1234567890"  }"#
    )

    assertConvertingJsonNumberToString(
      input: """
      {
        "number": 1234567890,
        "text": "hello"
      }
      """,
      key: "number",
      expected: """
      {
        "number": "1234567890",
        "text": "hello"
      }
      """
    )

    assertConvertingJsonNumberToString(
      input: """
      {
        "text": "hello",
        "number": 1234567890
      }
      """,
      key: "number",
      expected: """
      {
        "text": "hello",
        "number": "1234567890"
      }
      """
    )
  }

  func testConvertingStringToNumber() {
    assertConvertingJsonStringToNumber(
      input: #"{"number":"1234567890","text":"hello"}"#,
      key: "number",
      expected: #"{"number":1234567890,"text":"hello"}"#
    )

    assertConvertingJsonStringToNumber(
      input: #"{"text":"hello","number":"1234567890"}"#,
      key: "number",
      expected: #"{"text":"hello","number":1234567890}"#
    )

    assertConvertingJsonStringToNumber(
      input: #"{  "number"  :  "1234567890"  ,  "text"  :  "hello"  }"#,
      key: "number",
      expected: #"{  "number"  :  1234567890  ,  "text"  :  "hello"  }"#
    )

    assertConvertingJsonStringToNumber(
      input: #"{  "text"  :  "hello"  ,  "number"  :  "1234567890"  }"#,
      key: "number",
      expected: #"{  "text"  :  "hello"  ,  "number"  :  1234567890  }"#
    )

    assertConvertingJsonStringToNumber(
      input: """
      {
        "number": "1234567890",
        "text": "hello"
      }
      """,
      key: "number",
      expected: """
      {
        "number": 1234567890,
        "text": "hello"
      }
      """
    )

    assertConvertingJsonStringToNumber(
      input: """
      {
        "text": "hello",
        "number": "1234567890"
      }
      """,
      key: "number",
      expected: """
      {
        "text": "hello",
        "number": 1234567890
      }
      """
    )
  }
}

private func assertConvertingJsonNumberToString(
  input: String,
  key: String,
  expected: String,
  file: StaticString = #file,
  line: UInt = #line
) {
  XCTAssertNoDifference(
    String(
      data: convertJsonNumberToString(
        in: input.data(using: .utf8)!,
        at: key
      ),
      encoding: .utf8
    )!,
    expected,
    file: file,
    line: line
  )
}

private func assertConvertingJsonStringToNumber(
  input: String,
  key: String,
  expected: String,
  file: StaticString = #file,
  line: UInt = #line
) {
  XCTAssertNoDifference(
    String(
      data: convertJsonStringToNumber(
        in: input.data(using: .utf8)!,
        at: key
      ),
      encoding: .utf8
    )!,
    expected,
    file: file,
    line: line
  )
}
