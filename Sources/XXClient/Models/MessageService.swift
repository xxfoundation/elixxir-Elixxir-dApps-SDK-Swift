import Foundation

public struct MessageService: Equatable {
  public init(
    identifier: Data,
    tag: String,
    metadata: Data?
  ) {
    self.identifier = identifier
    self.tag = tag
    self.metadata = metadata
  }

  public var identifier: Data
  public var tag: String
  public var metadata: Data?
}

extension MessageService: Codable {
  enum CodingKeys: String, CodingKey {
    case identifier = "Identifier"
    case tag = "Tag"
    case metadata = "Metadata"
  }

  public static func decode(_ data: Data) throws -> Self {
    try JSONDecoder().decode(Self.self, from: data)
  }

  public func encode() throws -> Data {
    try JSONEncoder().encode(self)
  }
}

extension Array where Element == MessageService {
  public static func decode(_ data: Data) throws -> Self {
    try JSONDecoder().decode(Self.self, from: data)
  }

  public func encode() throws -> Data {
    try JSONEncoder().encode(self)
  }
}
