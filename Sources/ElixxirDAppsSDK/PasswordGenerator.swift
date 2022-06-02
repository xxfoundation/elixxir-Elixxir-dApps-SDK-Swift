import Bindings

public struct PasswordGenerator {
  public var run: () -> Data

  public func callAsFunction() -> Data {
    run()
  }
}

extension PasswordGenerator {
  public static let live = PasswordGenerator {
    guard let secret = BindingsGenerateSecret(32) else {
      fatalError("BindingsGenerateSecret returned `nil`")
    }
    return secret
  }
}

#if DEBUG
extension PasswordGenerator {
  public static let failing = PasswordGenerator {
    Data()
  }
}
#endif
