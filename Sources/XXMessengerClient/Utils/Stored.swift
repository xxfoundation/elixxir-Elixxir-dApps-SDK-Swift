import XCTestDynamicOverlay

public struct Stored<Value> {
  public var get: () -> Value
  public var set: (Value) -> Void

  public func callAsFunction() -> Value {
    get()
  }
}

extension Stored {
  public static func inMemory(_ value: Value) -> Stored<Value> {
    let memory = Memory(value)
    return Stored(
      get: { memory.value },
      set: { memory.value = $0 }
    )
  }

  public static func inMemory<V>() -> Stored<Optional<V>> where Value == Optional<V> {
    inMemory(nil)
  }
}

private final class Memory<Value> {
  init(_ value: Value) {
    self.value = value
  }

  var value: Value
}

extension Stored {
  public static func unimplemented(placeholder: Value) -> Stored<Value> {
    Stored<Value>(
      get: XCTUnimplemented("\(Self.self).get", placeholder: placeholder),
      set: XCTUnimplemented("\(Self.self).set")
    )
  }

  public static func unimplemented<V>() -> Stored<Optional<V>> where Value == Optional<V> {
    Stored<Value>(
      get: XCTUnimplemented("\(Self.self).get"),
      set: XCTUnimplemented("\(Self.self).set")
    )
  }
}
