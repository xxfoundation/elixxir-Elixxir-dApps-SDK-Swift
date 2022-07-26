import Foundation

public struct Progress: Equatable {
  public init(
    completed: Bool,
    transmitted: Int,
    total: Int,
    error: String?
  ) {
    self.completed = completed
    self.transmitted = transmitted
    self.total = total
    self.error = error
  }

  public var completed: Bool
  public var transmitted: Int
  public var total: Int
  public var error: String?
}

extension Progress: Codable {
  enum CodingKeys: String, CodingKey {
    case completed = "Completed"
    case transmitted = "Transmitted"
    case total = "Total"
    case error = "Err"
  }

  public static func decode(_ data: Data) throws -> Self {
    try JSONDecoder().decode(Self.self, from: data)
  }

  public func encode() throws -> Data {
    try JSONEncoder().encode(self)
  }
}
