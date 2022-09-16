import Foundation
import XCTestDynamicOverlay
import XXClient

public struct MessengerSearchContacts {
  public struct Query: Equatable {
    public init(
      username: String? = nil,
      email: String? = nil,
      phone: String? = nil
    ) {
      self.username = username
      self.email = email
      self.phone = phone
    }

    public var username: String?
    public var email: String?
    public var phone: String?
  }

  public enum Error: Swift.Error, Equatable {
    case notConnected
    case notLoggedIn
  }

  public var run: (Query) throws -> [Contact]

  public func callAsFunction(query: Query) throws -> [Contact] {
    try run(query)
  }
}

extension MessengerSearchContacts {
  public static func live(_ env: MessengerEnvironment) -> MessengerSearchContacts {
    MessengerSearchContacts { query in
      guard let e2e = env.e2e() else {
        throw Error.notConnected
      }
      guard let ud = env.ud() else {
        throw Error.notLoggedIn
      }
      var result: Result<[Contact], Swift.Error>!
      let semaphore = DispatchSemaphore(value: 0)
      _ = try env.searchUD(
        params: SearchUD.Params(
          e2eId: e2e.getId(),
          udContact: try ud.getContact(),
          facts: query.facts,
          singleRequestParamsJSON: env.getSingleUseParams()
        ),
        callback: UdSearchCallback { searchResult in
          switch searchResult {
          case .success(let contacts):
            result = .success(contacts)
          case .failure(let error):
            result = .failure(error)
          }
          semaphore.signal()
        }
      )
      semaphore.wait()
      return try result.get()
    }
  }
}

extension MessengerSearchContacts.Query {
  public var isEmpty: Bool {
    [username, email, phone]
      .compactMap { $0 }
      .map { $0.isEmpty == false }
      .contains(where: { $0 == true }) == false
  }

  var facts: [Fact] {
    var facts: [Fact] = []
    if let username = username, username.isEmpty == false {
      facts.set(.username, username)
    }
    if let email = email, email.isEmpty == false {
      facts.set(.email, email)
    }
    if let phone = phone, phone.isEmpty == false {
      facts.set(.phone, phone)
    }
    return facts
  }
}

extension MessengerSearchContacts {
  public static let unimplemented = MessengerSearchContacts(
    run: XCTUnimplemented("\(Self.self)")
  )
}
