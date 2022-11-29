import Foundation

public struct MessagePayload: Equatable {
  public init(
    text: String,
    replyingTo: Data? = nil
  ) {
    self.text = text
    self.replyingTo = replyingTo
  }

  public var text: String
  public var replyingTo: Data?
}

extension MessagePayload: Codable {
  enum CodingKeys: String, CodingKey {
    case text
    case replyingTo
  }

  public static func decode(_ data: Data) throws -> Self {
    try JSONDecoder().decode(Self.self, from: data)
  }

  public func encode() throws -> Data {
    try JSONEncoder().encode(self)
  }
}
