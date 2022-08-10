import Foundation

public struct SingleUseResponseReport: Equatable {
  public init(
    rounds: [Int],
    payload: Data,
    ephId: Int64,
    receptionId: Data,
    error: String?
  ) {
    self.rounds = rounds
    self.payload = payload
    self.ephId = ephId
    self.receptionId = receptionId
    self.error = error
  }

  public var rounds: [Int]
  public var payload: Data
  public var ephId: Int64
  public var receptionId: Data
  public var error: String?
}

extension SingleUseResponseReport: Codable {
  enum CodingKeys: String, CodingKey {
    case rounds = "Rounds"
    case payload = "Payload"
    case ephId = "EphID"
    case receptionId = "ReceptionID"
    case error = "Err"
  }

  public static func decode(_ data: Data) throws -> Self {
    try JSONDecoder().decode(Self.self, from: data)
  }

  public func encode() throws -> Data {
    try JSONEncoder().encode(self)
  }
}
