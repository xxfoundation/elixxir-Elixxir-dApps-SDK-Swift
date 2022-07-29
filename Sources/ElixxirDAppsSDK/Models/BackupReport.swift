import Foundation

public struct BackupReport: Equatable {
  public init(
    ids: [Data],
    params: Data
  ) {
    self.ids = ids
    self.params = params
  }

  public var ids: [Data]
  public var params: Data
}

extension BackupReport: Codable {
  enum CodingKeys: String, CodingKey {
    case ids = "BackupIdListJson"
    case params = "BackupParams"
  }

  public static func decode(_ data: Data) throws -> Self {
    try JSONDecoder().decode(Self.self, from: data)
  }

  public func encode() throws -> Data {
    try JSONEncoder().encode(self)
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let idsData = try container.decode(Data.self, forKey: .ids)
    ids = try JSONDecoder().decode([Data].self, from: idsData)
    params = try container.decode(Data.self, forKey: .params)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    let idsData = try JSONEncoder().encode(ids)
    try container.encode(idsData, forKey: .ids)
    try container.encode(params, forKey: .params)
  }
}
