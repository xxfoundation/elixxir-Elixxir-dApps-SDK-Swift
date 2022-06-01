import Bindings

public struct Client {

}

extension Client {
  public static func live(bindingsClient: BindingsClient) -> Client {
    Client()
  }
}

#if DEBUG
extension Client {
  public static let failing = Client()
}
#endif
