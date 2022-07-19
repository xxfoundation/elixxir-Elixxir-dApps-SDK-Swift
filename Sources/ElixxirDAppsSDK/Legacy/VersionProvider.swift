import Bindings

public struct VersionProvider {
  public var get: () -> String

  public func callAsFunction() -> String {
    get()
  }
}

extension VersionProvider {
  public static let live = VersionProvider(get: BindingsGetVersion)
}

#if DEBUG
extension VersionProvider {
  public static let failing = VersionProvider { fatalError("Not implemented") }
}
#endif
