import Foundation

public struct ReceivedFile: Equatable {
  public init(
    transferId: Data,
    senderId: Data,
    preview: Data?,
    name: String,
    type: String,
    size: Int
  ) {
    self.transferId = transferId
    self.senderId = senderId
    self.preview = preview
    self.name = name
    self.type = type
    self.size = size
  }

  public var transferId: Data
  public var senderId: Data
  public var preview: Data?
  public var name: String
  public var type: String
  public var size: Int
}

extension ReceivedFile: Codable {
  enum CodingKeys: String, CodingKey {
    case transferId = "TransferID"
    case senderId = "SenderID"
    case preview = "Preview"
    case name = "Name"
    case type = "Type"
    case size = "Size"
  }

  public static func decode(_ data: Data) throws -> Self {
    try JSONDecoder().decode(Self.self, from: data)
  }

  public func encode() throws -> Data {
    try JSONEncoder().encode(self)
  }
}
