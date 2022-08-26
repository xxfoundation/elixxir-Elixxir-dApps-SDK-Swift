import Foundation

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
