import Foundation

public struct Progress: Equatable {
  public init(
    completed: Bool,
    transmitted: Int,
    total: Int
  ) {
    self.completed = completed
    self.transmitted = transmitted
    self.total = total
  }

  public var completed: Bool
  public var transmitted: Int
  public var total: Int
}

extension Progress: Codable {
  enum CodingKeys: String, CodingKey {
    case completed = "Completed"
    case transmitted = "Transmitted"
    case total = "Total"
  }

  public static func decode(_ data: Data) throws -> Self {
    try JSONDecoder().decode(Self.self, from: data)
  }

  public func encode() throws -> Data {
    try JSONEncoder().encode(self)
  }
}
