import Bindings

public struct PasswordGenerator {
  public var run: () throws -> Data

  public func callAsFunction() throws -> Data {
    try run()
  }
}

extension PasswordGenerator {
  public static let live = PasswordGenerator {
    guard let secret = BindingsGenerateSecret(32) else {
      throw BindingsGenerateSecretUnknownError()
    }
    return secret
  }
}

#if DEBUG
extension PasswordGenerator {
  public static let failing = PasswordGenerator {
    struct NotImplemented: Error {}
    throw NotImplemented()
  }
}
#endif
