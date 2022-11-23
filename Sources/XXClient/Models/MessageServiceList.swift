import Foundation

public typealias MessageServiceList = Array<MessageServiceListElement>

extension MessageServiceList {
  public static func decode(_ data: Data) throws -> Self {
    try JSONDecoder().decode(Self.self, from: data)
  }

  public func encode() throws -> Data {
    try JSONEncoder().encode(self)
  }
}

public struct MessageServiceListElement: Equatable {
  public init(id: Data, services: [MessageService]) {
    self.id = id
    self.services = services
  }

  public var id: Data
  public var services: [MessageService]
}

extension MessageServiceListElement: Codable {
  enum CodingKeys: String, CodingKey {
    case id = "Id"
    case services = "Services"
  }

  public static func decode(_ data: Data) throws -> Self {
    try JSONDecoder().decode(Self.self, from: data)
  }

  public func encode() throws -> Data {
    try JSONEncoder().encode(self)
  }
}
