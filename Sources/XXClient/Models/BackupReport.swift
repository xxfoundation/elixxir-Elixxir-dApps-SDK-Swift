import Foundation

public struct BackupReport: Equatable {
  public init(
    restoredContacts: [Data],
    params: String
  ) {
    self.restoredContacts = restoredContacts
    self.params = params
  }

  public var restoredContacts: [Data]
  public var params: String
}

extension BackupReport: Codable {
  enum CodingKeys: String, CodingKey {
    case restoredContacts = "RestoredContacts"
    case params = "Params"
  }

  public static func decode(_ data: Data) throws -> Self {
    try JSONDecoder().decode(Self.self, from: data)
  }

  public func encode() throws -> Data {
    try JSONEncoder().encode(self)
  }
}
