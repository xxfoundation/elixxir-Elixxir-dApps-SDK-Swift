import Foundation
import XCTestDynamicOverlay

public struct Contact {
  public init(
    data: Data,
    getId: @escaping () throws -> Data,
    getPublicKey: @escaping () throws -> Data,
    getFacts: @escaping () throws -> [Fact],
    setFacts: @escaping (Data, [Fact]) throws -> Data
  ) {
    self.data = data
    self.getId = getId
    self.getPublicKey = getPublicKey
    self.getFacts = getFacts
    self._setFacts = setFacts
  }

  public var data: Data
  public var getId: () throws -> Data
  public var getPublicKey: () throws -> Data
  public var getFacts: () throws -> [Fact]
  public var _setFacts: (Data, [Fact]) throws -> Data

  public mutating func setFacts(_ facts: [Fact]) throws {
    data = try _setFacts(data, facts)
  }
}

extension Contact: Equatable {
  public static func == (lhs: Contact, rhs: Contact) -> Bool {
    lhs.data == rhs.data
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
      getId: { try getIdFromContact(data) },
      getPublicKey: { try getPublicKeyFromContact(data) },
      getFacts: { try getFactsFromContact(data) },
      setFacts: { try setFactsOnContact(contactData: $0, facts: $1) }
    )
  }
}

extension Contact {
  public static func unimplemented(_ data: Data) -> Contact {
    Contact(
      data: data,
      getId: XCTUnimplemented("\(Self.self).getId"),
      getPublicKey: XCTUnimplemented("\(Self.self).getPublicKey"),
      getFacts: XCTUnimplemented("\(Self.self).getFacts"),
      setFacts: XCTUnimplemented("\(Self.self).updateFacts")
    )
  }
}
