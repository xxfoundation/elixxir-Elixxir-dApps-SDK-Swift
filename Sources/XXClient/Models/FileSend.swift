import Foundation

public struct FileSend: Equatable {
  public init(
    name: String,
    type: String,
    preview: Data?,
    contents: Data
  ) {
    self.name = name
    self.type = type
    self.preview = preview
    self.contents = contents
  }

  public var name: String
  public var type: String
  public var preview: Data?
  public var contents: Data
}

extension FileSend: Codable {
  enum CodingKeys: String, CodingKey {
    case name = "Name"
    case type = "Type"
    case preview = "Preview"
    case contents = "Contents"
  }

  public static func decode(_ data: Data) throws -> Self {
    try JSONDecoder().decode(Self.self, from: data)
  }

  public func encode() throws -> Data {
    try JSONEncoder().encode(self)
  }
}
