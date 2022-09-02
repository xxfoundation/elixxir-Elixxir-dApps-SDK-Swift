import Foundation

public struct TrackServicesCallbackResult: Equatable {
  public init(id: Data, services: [MessageService]) {
    self.id = id
    self.services = services
  }

  public var id: Data
  public var services: [MessageService]
}

extension TrackServicesCallbackResult: Codable {
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

extension Array where Element == TrackServicesCallbackResult {
  public static func decode(_ data: Data) throws -> Self {
    try JSONDecoder().decode(Self.self, from: data)
  }

  public func encode() throws -> Data {
    try JSONEncoder().encode(self)
  }
}
