import Bindings

public struct GitVersionProvider {
  public var get: () -> String

  public func callAsFunction() -> String {
    get()
  }
}

extension GitVersionProvider {
  public static let live = GitVersionProvider(get: BindingsGetGitVersion)
}

#if DEBUG
extension GitVersionProvider {
  public static let failing = GitVersionProvider { fatalError("Not implemented") }
}
#endif
