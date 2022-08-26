import Foundation
import XCTestDynamicOverlay

public struct Contact {
  public init(
    data: Data,
    getId: @escaping () throws -> Data,
    getPublicKey: @escaping () throws -> Data,
    getFacts: @escaping () throws -> [Fact]
  ) {
    self.data = data
    self.getId = getId
    self.getPublicKey = getPublicKey
    self.getFacts = getFacts
  }

  public var data: Data
  public var getId: () throws -> Data
  public var getPublicKey: () throws -> Data
  public var getFacts: () throws -> [Fact]
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
    getFactsFromContact: GetFactsFromContact = .live
  ) -> Contact {
    Contact(
      data: data,
      getId: { try getIdFromContact(data) },
      getPublicKey: { try getPublicKeyFromContact(data) },
      getFacts: { try getFactsFromContact(data) }
    )
  }
}

extension Contact {
  public static func unimplemented(_ data: Data) -> Contact {
    Contact(
      data: data,
      getId: XCTUnimplemented("\(Self.self).getId"),
      getPublicKey: XCTUnimplemented("\(Self.self).getPublicKey"),
      getFacts: XCTUnimplemented("\(Self.self).getFacts")
    )
  }
}
