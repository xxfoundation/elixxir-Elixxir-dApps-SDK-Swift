import Foundation

public struct MakeContact {
  public var run: (Data) -> Contact

  public func callAsFunction(_ data: Data) -> Contact {
    run(data)
  }
}

extension MakeContact {
  public static func live(
    getIdFromContact: GetIdFromContact = .live,
    getPublicKeyFromContact: GetPublicKeyFromContact = .live,
    getFactsFromContact: GetFactsFromContact = .live
  ) -> MakeContact {
    MakeContact { data in
      Contact(
        data: data,
        getId: { try getIdFromContact(data) },
        getPublicKey: { try getPublicKeyFromContact(data) },
        getFacts: { try getFactsFromContact(data) }
      )
    }
  }
}
