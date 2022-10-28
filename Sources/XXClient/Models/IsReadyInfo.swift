import Foundation

public struct IsReadyInfo: Equatable {
  public init(isReady: Bool, howClose: Double) {
    self.isReady = isReady
    self.howClose = howClose
  }

  public var isReady: Bool
  public var howClose: Double
}

extension IsReadyInfo: Codable {
  enum CodingKeys: String, CodingKey {
    case isReady = "IsReady"
    case howClose = "HowClose"
  }

  public static func decode(_ data: Data) throws -> Self {
    try JSONDecoder().decode(Self.self, from: data)
  }

  public func encode() throws -> Data {
    try JSONEncoder().encode(self)
  }
}
