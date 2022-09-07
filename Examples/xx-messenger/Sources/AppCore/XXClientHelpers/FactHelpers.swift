import XXClient

// TODO: Move to XXClient library

public enum FactType: Equatable {
  case username
  case email
  case phone
  case other(Int)

  public static let knownTypes: [Self] = [.username, .email, .phone]

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

extension Array where Element == Fact {
  public func get(_ type: FactType) -> Fact? {
    first(where: { $0.type == type.rawValue })
  }

  public mutating func set(_ type: FactType, _ value: String?) {
    removeAll(where: { $0.type == type.rawValue })
    if let value = value {
      append(Fact(fact: value, type: type.rawValue))
      sort(by: { $0.type < $1.type })
    }
  }
}

extension Contact {
  public func getFact(_ type: FactType) throws -> Fact? {
    try getFacts().get(type)
  }

  public mutating func setFact(_ type: FactType, _ value: String?) throws {
    var facts = try getFacts()
    facts.set(type, value)
    try setFacts(facts)
  }
}
