import Foundation

public struct DHKey: Equatable {
  public init(value: String, fingerprint: UInt64) {
    self.value = value
    self.fingerprint = fingerprint
  }

  public var value: String
  public var fingerprint: UInt64
}

extension DHKey: Decodable {
  enum CodingKeys: String, CodingKey {
    case value = "Value"
    case fingerprint = "Fingerprint"
  }

  public static func decode(_ data: Data) throws -> Self {
    let data = convertJsonNumberToString(in: data, at: "Value")
    return try JSONDecoder().decode(Self.self, from: data)
  }
}
