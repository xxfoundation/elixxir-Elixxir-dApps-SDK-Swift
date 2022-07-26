import Foundation

public struct EventReport: Equatable {
  public init(
    priority: Int,
    category: String,
    eventType: String,
    details: String
  ) {
    self.priority = priority
    self.category = category
    self.eventType = eventType
    self.details = details
  }

  public var priority: Int
  public var category: String
  public var eventType: String
  public var details: String
}

extension EventReport: Codable {
  enum CodingKeys: String, CodingKey {
    case priority = "Priority"
    case category = "Category"
    case eventType = "EventType"
    case details = "Details"
  }

  public static func decode(_ data: Data) throws -> EventReport {
    try JSONDecoder().decode(Self.self, from: data)
  }

  public func encode() throws -> Data {
    try JSONEncoder().encode(self)
  }
}
