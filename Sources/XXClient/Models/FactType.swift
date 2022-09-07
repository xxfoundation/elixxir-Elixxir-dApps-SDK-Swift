import Foundation

public enum FactType: Equatable {
  case username
  case email
  case phone
  case other(Int)

  public static let knownTypes: [FactType] = [.username, .email, .phone]

  public init(rawValue: Int) {
    if let known = FactType.knownTypes.first(where: { $0.rawValue == rawValue }) {
      self = known
    } else {
      self = .other(rawValue)
    }
  }

  public var rawValue: Int {
    switch self {
    case .username: return 0
    case .email: return 1
    case .phone: return 2
    case .other(let rawValue): return rawValue
    }
  }
}

extension FactType: Codable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.init(rawValue: try container.decode(Int.self))
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(rawValue)
  }
}
