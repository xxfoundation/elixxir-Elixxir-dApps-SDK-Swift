public struct ContactFact: Equatable {
  public init(
    fact: String,
    type: Int
  ) {
    self.fact = fact
    self.type = type
  }

  public var fact: String
  public var type: Int
}

extension ContactFact: Codable {
  enum CodingKeys: String, CodingKey {
    case fact = "Fact"
    case type = "Type"
  }
}
