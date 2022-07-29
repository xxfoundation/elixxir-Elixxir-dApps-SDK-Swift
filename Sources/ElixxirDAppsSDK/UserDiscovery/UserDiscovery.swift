import Bindings

public struct UserDiscovery {
  public var setAlternative: UserDiscoverySetAlternative
  public var getId: UserDiscoveryGetId
  public var getContact: UserDiscoveryGetContact
  public var getFacts: UserDiscoveryGetFacts
  public var sendRegisterFact: UserDiscoverySendRegisterFact
  public var confirmFact: UserDiscoveryConfirmFact
  public var removeFact: UserDiscoveryRemoveFact
  public var permanentDeleteAccount: UserDiscoveryPermanentDeleteAccount
}

extension UserDiscovery {
  public static func live(_ bindingsUD: BindingsUserDiscovery) -> UserDiscovery {
    UserDiscovery(
      setAlternative: .live(bindingsUD),
      getId: .live(bindingsUD),
      getContact: .live(bindingsUD),
      getFacts: .live(bindingsUD),
      sendRegisterFact: .live(bindingsUD),
      confirmFact: .live(bindingsUD),
      removeFact: .live(bindingsUD),
      permanentDeleteAccount: .live(bindingsUD)
    )
  }
}

extension UserDiscovery {
  public static let unimplemented = UserDiscovery(
    setAlternative: .unimplemented,
    getId: .unimplemented,
    getContact: .unimplemented,
    getFacts: .unimplemented,
    sendRegisterFact: .unimplemented,
    confirmFact: .unimplemented,
    removeFact: .unimplemented,
    permanentDeleteAccount: .unimplemented
  )
}
