import CustomDump
import XCTest
@testable import XXClient

final class ConvertJsonNumberToStringTests: XCTestCase {
  func testConverting() {
    assert(
      input: #"{"number":1234567890,"text":"hello"}"#,
      key: "number",
      expected: #"{"number":"1234567890","text":"hello"}"#
    )

    assert(
      input: #"{"text":"hello","number":1234567890}"#,
      key: "number",
      expected: #"{"text":"hello","number":"1234567890"}"#
    )

    assert(
      input: #"{  "number"  :  1234567890  ,  "text"  :  "hello"  }"#,
      key: "number",
      expected: #"{  "number"  :  "1234567890"  ,  "text"  :  "hello"  }"#
    )

    assert(
      input: #"{  "text"  :  "hello"  ,  "number"  :  1234567890  }"#,
      key: "number",
      expected: #"{  "text"  :  "hello"  ,  "number"  :  "1234567890"  }"#
    )

    assert(
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

    assert(
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
}

private func assert(
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
