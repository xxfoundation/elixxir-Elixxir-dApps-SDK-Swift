import XCTestDynamicOverlay
import XXClient

public struct MessengerMyContact {
  public enum IncludeFacts: Equatable {
    case all
    case types(Set<FactType>)
  }

  public enum Error: Swift.Error, Equatable {
    case notConnected
    case notLoggedIn
  }

  public var run: (IncludeFacts?) throws -> XXClient.Contact

  public func callAsFunction(includeFacts: IncludeFacts? = .all) throws -> XXClient.Contact {
    try run(includeFacts)
  }
}

extension MessengerMyContact {
  public static func live(_ env: MessengerEnvironment) -> MessengerMyContact {
    MessengerMyContact { includeFacts in
      guard let e2e = env.e2e() else {
        throw Error.notConnected
      }
      var contact = e2e.getContact()
      if let includeFacts {
        guard let ud = env.ud() else {
          throw Error.notLoggedIn
        }
        let udFacts = try ud.getFacts()
        switch includeFacts {
        case .all:
          try contact.setFacts(udFacts)

        case .types(let types):
          try contact.setFacts(udFacts.filter { types.contains($0.type) })
        }
      }
      return contact
    }
  }
}

extension MessengerMyContact {
  public static let unimplemented = MessengerMyContact(
    run: XCTUnimplemented("\(Self.self)")
  )
}
