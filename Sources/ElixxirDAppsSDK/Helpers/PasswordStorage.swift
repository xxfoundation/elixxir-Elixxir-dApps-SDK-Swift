import Foundation
import XCTestDynamicOverlay

public struct PasswordStorage {
  public struct MissingPasswordError: Error, Equatable {
    public init() {}
  }

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

extension PasswordStorage {
  public static let unimplemented = PasswordStorage(
    save: XCTUnimplemented("\(Self.self).save"),
    load: XCTUnimplemented("\(Self.self).load")
  )
}
