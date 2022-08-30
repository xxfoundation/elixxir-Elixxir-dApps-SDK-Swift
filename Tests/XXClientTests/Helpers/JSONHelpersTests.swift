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

  func testConvertingNumberToStringByLength() {
    assertConvertingJsonNumberToString(
      input: """
      {
        "text": "hello",
        "number1": 123456789,
        "number2": 1234567890,
        "number3": 123456789,
        "number4": 1234567890
      }
      """,
      minNumberLength: 10,
      expected: """
      {
        "text": "hello",
        "number1": 123456789,
        "number2": "1234567890",
        "number3": 123456789,
        "number4": "1234567890"
      }
      """
    )

    assertConvertingJsonNumberToString(
      input: #"{"text":"hello","number1":123456789,"number2":1234567890,"number3":123456789,"number4":1234567890}"#,
      minNumberLength: 10,
      expected: #"{"text":"hello","number1":123456789,"number2":"1234567890","number3":123456789,"number4":"1234567890"}"#
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

private func assertConvertingJsonNumberToString(
  input: String,
  minNumberLength: Int,
  expected: String,
  file: StaticString = #file,
  line: UInt = #line
) {
  XCTAssertNoDifference(
    String(
      data: convertJsonNumberToString(
        in: input.data(using: .utf8)!,
        minNumberLength: minNumberLength
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
