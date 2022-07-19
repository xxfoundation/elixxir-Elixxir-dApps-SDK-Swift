import Bindings

public struct ClientE2E {
    public var getId: ClientE2EIdProvider
    public var getContactFromIdentity: ContactFromIdentityProvider
}

extension ClientE2E {
    public static func live(bindingsClientE2E: BindingsE2e) -> ClientE2E {
        ClientE2E(
            getId: .live(bindingsClientE2E: bindingsClientE2E),
            getContactFromIdentity: .live(bindingsClientE2E: bindingsClientE2E)
        )
    }
}

#if DEBUG
extension ClientE2E {
    public static let failing = ClientE2E(
        getId: .failing,
        getContactFromIdentity: .failing
    )
}
#endif
