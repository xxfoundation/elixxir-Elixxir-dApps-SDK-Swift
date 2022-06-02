import Bindings

public struct PasswordGenerator {
  public var run: (Int) -> Data

  public func callAsFunction(numBytes: Int = 32) -> Data {
    run(numBytes)
  }
}

extension PasswordGenerator {
  public static let live = PasswordGenerator { numBytes in
    guard let secret = BindingsGenerateSecret(numBytes) else {
      fatalError("BindingsGenerateSecret returned `nil`")
    }
    return secret
  }
}

#if DEBUG
extension PasswordGenerator {
  public static let failing = PasswordGenerator { _ in
    Data()
  }
}
#endif
