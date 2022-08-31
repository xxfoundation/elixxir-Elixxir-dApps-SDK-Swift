import Foundation

public struct NotificationReport: Equatable {
  public enum ReportType: String, Equatable {
    case `default`
    case request
    case reset
    case confirm
    case silent
    case e2e
    case group
    case endFT
    case groupRQ
  }

  public init(
    forMe: Bool,
    type: NotificationReport.ReportType,
    source: Data
  ) {
    self.forMe = forMe
    self.type = type
    self.source = source
  }

  public var forMe: Bool
  public var type: ReportType
  public var source: Data
}

extension NotificationReport.ReportType: Codable {}

extension NotificationReport: Codable {
  enum CodingKeys: String, CodingKey {
    case forMe = "ForMe"
    case type = "Type"
    case source = "Source"
  }

  public static func decode(_ data: Data) throws -> Self {
    try JSONDecoder().decode(Self.self, from: data)
  }

  public func encode() throws -> Data {
    try JSONEncoder().encode(self)
  }
}
