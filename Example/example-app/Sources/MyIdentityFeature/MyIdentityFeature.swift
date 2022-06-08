import ComposableArchitecture

public struct MyIdentityState: Equatable {
  public init() {}
}

public enum MyIdentityAction: Equatable {}

public struct MyIdentityEnvironment {
  public init() {}
}

public let myIdentityReducer = Reducer<MyIdentityState, MyIdentityAction, MyIdentityEnvironment>.empty

#if DEBUG
extension MyIdentityEnvironment {
  public static let failing = MyIdentityEnvironment()
}
#endif
