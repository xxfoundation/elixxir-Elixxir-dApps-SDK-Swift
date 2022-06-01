import Foundation

public struct PasswordStorage {
  public init(
    save: @escaping (Data) throws -> Void,
    load: @escaping () throws -> Data
  ) {
    self.save = save
    self.load = load
  }

  public var save: (Data) throws -> Void
  public var load: () throws -> Data
}

#if DEBUG
extension PasswordStorage {
  public static let failing = PasswordStorage(
    save: { _ in
      struct NotImplemented: Error {}
      throw NotImplemented()
    },
    load: {
      struct NotImplemented: Error {}
      throw NotImplemented()
    }
  )
}
#endif
