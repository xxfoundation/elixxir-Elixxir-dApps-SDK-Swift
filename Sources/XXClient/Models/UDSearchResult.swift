import Foundation

public struct UDSearchResult: Equatable {
  public init(
    id: Data,
    publicKey: Data,
    facts: [Fact]
  ) {
    self.id = id
    self.publicKey = publicKey
    self.facts = facts
  }

  public var id: Data
  public var publicKey: Data
  public var facts: [Fact]
}
