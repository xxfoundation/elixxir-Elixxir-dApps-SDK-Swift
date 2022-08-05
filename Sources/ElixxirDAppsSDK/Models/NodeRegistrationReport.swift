import Foundation

public struct NodeRegistrationReport: Equatable {
  public init(
    registered: Int,
    total: Int
  ) {
    self.registered = registered
    self.total = total
  }

  public var registered: Int
  public var total: Int
}

extension NodeRegistrationReport {
  public var ratio: Double {
    guard total != 0 else { return 0 }
    return Double(registered) / Double(total)
  }
}

extension NodeRegistrationReport: Codable {
  enum CodingKeys: String, CodingKey {
    case registered = "NumberOfNodesRegistered"
    case total = "NumberOfNodes"
  }

  public static func decode(_ data: Data) throws -> Self {
    try JSONDecoder().decode(Self.self, from: data)
  }

  public func encode() throws -> Data {
    try JSONEncoder().encode(self)
  }
}
