import Foundation

public struct SingleUseResponseReport: Equatable {
  public init(
    rounds: [Int],
    payload: Data,
    receptionId: ReceptionId,
    error: String?
  ) {
    self.rounds = rounds
    self.payload = payload
    self.receptionId = receptionId
    self.error = error
  }

  public var rounds: [Int]
  public var payload: Data
  public var receptionId: ReceptionId
  public var error: String?
}

extension SingleUseResponseReport {
  public struct ReceptionId: Equatable {
    public init(
      ephId: [Int],
      source: Data
    ) {
      self.ephId = ephId
      self.source = source
    }

    public var ephId: [Int]
    public var source: Data
  }
}

extension SingleUseResponseReport: Codable {
  enum CodingKeys: String, CodingKey {
    case rounds = "Rounds"
    case payload = "Payload"
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

extension SingleUseResponseReport.ReceptionId: Codable {
  enum CodingKeys: String, CodingKey {
    case ephId = "EphId"
    case source = "Source"
  }
}
