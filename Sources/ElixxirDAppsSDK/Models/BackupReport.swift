import Foundation

public struct BackupReport: Equatable {
  public init(
    ids: Data,
    params: Data
  ) {
    self.ids = ids
    self.params = params
  }

  public var ids: Data
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
}
