import Foundation
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
  public static func userDefaults<T>(
    key: String,
    userDefaults: UserDefaults = .standard
  ) -> Stored<T?> where T: Codable {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    return Stored<T?>(
      get: {
        guard let data = userDefaults.data(forKey: key) else { return nil }
        return try? decoder.decode(T.self, from: data)
      },
      set: { newValue in
        let data = try? encoder.encode(newValue)
        userDefaults.set(data, forKey: key)
      }
    )
  }
}

extension Stored {
  public struct MissingValueError: Error, Equatable {
    public init(typeDescription: String) {
      self.typeDescription = typeDescription
    }

    public var typeDescription: String
  }

  public func tryGet<T>() throws -> T where Value == Optional<T> {
    guard let value = get() else {
      throw MissingValueError(typeDescription: "\(Self.self)")
    }
    return value
  }
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
