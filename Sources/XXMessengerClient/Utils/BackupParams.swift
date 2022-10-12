import Foundation

public struct BackupParams: Equatable {
  public init(
    username: String
  ) {
    self.username = username
  }

  public var username: String
}

extension BackupParams: Codable {
  public static func decode(_ data: Data) throws -> Self {
    try JSONDecoder().decode(Self.self, from: data)
  }

  public func encode() throws -> Data {
    try JSONEncoder().encode(self)
  }
}
