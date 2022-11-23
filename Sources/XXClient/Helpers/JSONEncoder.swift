import CustomDump
import Foundation

class JSONEncoder: Foundation.JSONEncoder {
  override init() {
    super.init()
  }

  override func encode<T>(_ value: T) throws -> Data where T: Encodable {
    do {
      var data = try super.encode(value)
      data = Self.convertStringToNumber(in: data, at: "Value")
      return data
    } catch {
      throw JSONEncodingError(error, value: value)
    }
  }

  static func convertStringToNumber(
    in input: Data,
    at key: String
  ) -> Data {
    guard var string = String(data: input, encoding: .utf8) else {
      return input
    }
    string = string.replacingOccurrences(
      of: #""\#(key)"( *):( *)"([0-9]+)"( *)(,*)"#,
      with: #""\#(key)"$1:$2$3$4$5"#,
      options: [.regularExpression]
    )
    guard let output = string.data(using: .utf8) else {
      return input
    }
    return output
  }
}

public struct JSONEncodingError: Error, CustomStringConvertible {
  public init(_ underlayingError: Error, value: Any) {
    self.underlayingError = underlayingError
    self.value = value
  }

  public var underlayingError: Error
  public var value: Any

  public var description: String {
    var description = ""
    customDump(self, to: &description)
    return description
  }
}
