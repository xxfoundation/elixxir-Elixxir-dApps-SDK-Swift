import Bindings

public struct DependenciesProvider {
  public var get: () -> String

  public func callAsFunction() -> String {
    get()
  }
}

extension DependenciesProvider {
  public static let live = DependenciesProvider(get: BindingsGetDependencies)
}

#if DEBUG
extension DependenciesProvider {
  public static let failing = DependenciesProvider { fatalError("Not implemented") }
}
#endif
