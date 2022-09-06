import AppCore
import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay
import XXClient
import XXModels

public struct UserSearchResultState: Equatable, Identifiable {
  public init(
    id: Data,
    xxContact: XXClient.Contact,
    dbContact: XXModels.Contact? = nil,
    username: String? = nil,
    email: String? = nil,
    phone: String? = nil
  ) {
    self.id = id
    self.xxContact = xxContact
    self.dbContact = dbContact
    self.username = username
    self.email = email
    self.phone = phone
  }

  public var id: Data
  public var xxContact: XXClient.Contact
  public var dbContact: XXModels.Contact?
  public var username: String?
  public var email: String?
  public var phone: String?
}

public enum UserSearchResultAction: Equatable {
  case start
  case didUpdateContact(XXModels.Contact?)
  case sendRequestButtonTapped
}

public struct UserSearchResultEnvironment {
  public init(
    db: DBManagerGetDB,
    mainQueue: AnySchedulerOf<DispatchQueue>,
    bgQueue: AnySchedulerOf<DispatchQueue>
  ) {
    self.db = db
    self.mainQueue = mainQueue
    self.bgQueue = bgQueue
  }

  public var db: DBManagerGetDB
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public var bgQueue: AnySchedulerOf<DispatchQueue>
}

#if DEBUG
extension UserSearchResultEnvironment {
  public static let unimplemented = UserSearchResultEnvironment(
    db: .unimplemented,
    mainQueue: .unimplemented,
    bgQueue: .unimplemented
  )
}
#endif

public let userSearchResultReducer = Reducer<UserSearchResultState, UserSearchResultAction, UserSearchResultEnvironment>
{ state, action, env in
  enum DBFetchEffectID {}

  switch action {
  case .start:
    let facts = (try? state.xxContact.getFacts()) ?? []
    state.username = facts.first(where: { $0.type == 0 })?.fact
    state.email = facts.first(where: { $0.type == 1 })?.fact
    state.phone = facts.first(where: { $0.type == 2 })?.fact
    return try! env.db().fetchContactsPublisher(.init(id: [state.id]))
      .assertNoFailure()
      .map(\.first)
      .map(UserSearchResultAction.didUpdateContact)
      .subscribe(on: env.bgQueue)
      .receive(on: env.mainQueue)
      .eraseToEffect()
      .cancellable(id: DBFetchEffectID.self, cancelInFlight: true)

  case .didUpdateContact(let contact):
    state.dbContact = contact
    return .none

  case .sendRequestButtonTapped:
    return .none
  }
}
