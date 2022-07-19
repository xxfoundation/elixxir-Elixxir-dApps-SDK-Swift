//import Bindings
//
//public struct ClientE2ELogin {
//    public var login: (Client) throws -> ClientE2E
//    
//    public func callAsFunction(with client: Client) throws -> ClientE2E {
//        try login(client)
//    }
//}
//
//extension ClientE2ELogin {
//    public static let live = ClientE2ELogin { client in
//        var error: NSError?
//        let cMixId = client.getId()
//        let myIdentity = try client.makeIdentity()
//        let encoder = JSONEncoder()
//        let myIdentityData = try encoder.encode(myIdentity)
//        let bindingsClientE2E = BindingsLoginE2e(cMixId, nil, myIdentityData, &error)
//        if let error = error {
//            throw error
//        }
//        guard let bindingsClientE2E = bindingsClientE2E else {
//            fatalError("BindingsLoginE2E returned `nil` without providing error")
//        }
//        return ClientE2E.live(bindingsClientE2E: bindingsClientE2E)
//    }
//}
//
//#if DEBUG
//extension ClientE2ELogin {
//    public static let failing = ClientE2ELogin { _ in
//        struct NotImplemented: Error {}
//        throw NotImplemented()
//    }
//}
//#endif
