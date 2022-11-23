import CustomDump
import Foundation

class JSONDecoder: Foundation.JSONDecoder {
  override init() {
    super.init()
  }

  override func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable {
    do {
      let data = Self.convertNumberToString(in: data, at: "Value")
      return try super.decode(type, from: data)
    } catch {
      throw JSONDecodingError(error, data: data)
    }
  }

  static func convertNumberToString(
    in input: Data,
    at key: String
  ) -> Data {
    guard var string = String(data: input, encoding: .utf8) else {
      return input
    }
    string = string.replacingOccurrences(
      of: #""\#(key)"( *):( *)([0-9]+)( *)(,*)"#,
      with: #""\#(key)"$1:$2"$3"$4$5"#,
      options: [.regularExpression]
    )
    guard let output = string.data(using: .utf8) else {
      return input
    }
    return output
  }
}

public struct JSONDecodingError: Error, CustomStringConvertible, CustomDumpReflectable {
  public init(_ underlayingError: Error, data: Data) {
    self.underlayingError = underlayingError
    self.data = data
    self.string = String(data: data, encoding: .utf8)
  }

  public var underlayingError: Error
  public var data: Data
  public var string: String?

  public var description: String {
    var description = ""
    customDump(self, to: &description)
    return description
  }

  public var customDumpMirror: Mirror {
    Mirror(
      self,
      children: [
        "underlayingError": underlayingError,
        "data": String(data: data, encoding: .utf8) ?? data
      ],
      displayStyle: .struct
    )
  }
}
