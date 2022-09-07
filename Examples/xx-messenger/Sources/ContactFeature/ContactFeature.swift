import AppCore
import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay
import XXClient
import XXMessengerClient
import XXModels

public struct ContactState: Equatable {
  public init(
    id: Data,
    dbContact: XXModels.Contact? = nil,
    xxContact: XXClient.Contact? = nil
  ) {
    self.id = id
    self.dbContact = dbContact
    self.xxContact = xxContact
  }

  public var id: Data
  public var dbContact: XXModels.Contact?
  public var xxContact: XXClient.Contact?
}

public enum ContactAction: Equatable {
  case start
}

public struct ContactEnvironment {
  public init(
    messenger: Messenger,
    db: DBManagerGetDB,
    mainQueue: AnySchedulerOf<DispatchQueue>,
    bgQueue: AnySchedulerOf<DispatchQueue>
  ) {
    self.messenger = messenger
    self.db = db
    self.mainQueue = mainQueue
    self.bgQueue = bgQueue
  }

  public var messenger: Messenger
  public var db: DBManagerGetDB
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public var bgQueue: AnySchedulerOf<DispatchQueue>
}

#if DEBUG
extension ContactEnvironment {
  public static let unimplemented = ContactEnvironment(
    messenger: .unimplemented,
    db: .unimplemented,
    mainQueue: .unimplemented,
    bgQueue: .unimplemented
  )
}
#endif

public let contactReducer = Reducer<ContactState, ContactAction, ContactEnvironment>
{ state, action, env in
  switch action {
  case .start:
    return .none
  }
}
