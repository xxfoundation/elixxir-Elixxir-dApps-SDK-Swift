import Foundation

public struct Contact {
  public init(
    data: Data,
    getIdFromContact: GetIdFromContact,
    getPublicKeyFromContact: GetPublicKeyFromContact,
    getFactsFromContact: GetFactsFromContact,
    setFactsOnContact: SetFactsOnContact
  ) {
    self.data = data
    self.getIdFromContact = getIdFromContact
    self.getPublicKeyFromContact = getPublicKeyFromContact
    self.getFactsFromContact = getFactsFromContact
    self.setFactsOnContact = setFactsOnContact
  }

  public var data: Data
  public var getIdFromContact: GetIdFromContact
  public var getPublicKeyFromContact: GetPublicKeyFromContact
  public var getFactsFromContact: GetFactsFromContact
  public var setFactsOnContact: SetFactsOnContact

  public func getId() throws -> Data {
    try getIdFromContact(data)
  }

  public func getPublicKey() throws -> Data {
    try getPublicKeyFromContact(data)
  }

  public func getFacts() throws -> [Fact] {
    try getFactsFromContact(data)
  }

  public mutating func setFacts(_ facts: [Fact]) throws {
    data = try setFactsOnContact(contactData: data, facts: facts)
  }
}

extension Contact: Equatable {
  public static func == (lhs: Contact, rhs: Contact) -> Bool {
    lhs.data == rhs.data
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

extension Contact {
  public static func live(
    _ data: Data,
    getIdFromContact: GetIdFromContact = .live,
    getPublicKeyFromContact: GetPublicKeyFromContact = .live,
    getFactsFromContact: GetFactsFromContact = .live,
    setFactsOnContact: SetFactsOnContact = .live
  ) -> Contact {
    Contact(
      data: data,
      getIdFromContact: getIdFromContact,
      getPublicKeyFromContact: getPublicKeyFromContact,
      getFactsFromContact: getFactsFromContact,
      setFactsOnContact: setFactsOnContact
    )
  }
}

extension Contact {
  public static func unimplemented(_ data: Data) -> Contact {
    Contact(
      data: data,
      getIdFromContact: .unimplemented,
      getPublicKeyFromContact: .unimplemented,
      getFactsFromContact: .unimplemented,
      setFactsOnContact: .unimplemented
    )
  }
}
