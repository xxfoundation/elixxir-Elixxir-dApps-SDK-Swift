import Foundation

public struct MessagePayload: Equatable {
  public init(text: String) {
    self.text = text
  }

  public var text: String
}

extension MessagePayload: Codable {
  enum CodingKeys: String, CodingKey {
    case text
  }

  public static func decode(_ data: Data) throws -> Self {
    try JSONDecoder().decode(Self.self, from: data)
  }

  public func encode() throws -> Data {
    try JSONEncoder().encode(self)
  }
}
