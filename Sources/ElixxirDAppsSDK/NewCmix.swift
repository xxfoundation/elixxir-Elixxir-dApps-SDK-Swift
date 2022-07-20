import Bindings
import XCTestDynamicOverlay

public struct NewCmix {
  public init(run: @escaping (String, String, Data, String?) throws -> Bool) {
    self.run = run
  }

  public var run: (String, String, Data, String?) throws -> Bool

  public func callAsFunction(
    ndfJSON: String,
    storageDir: String,
    password: Data,
    registrationCode: String?
  ) throws -> Bool {
    try run(ndfJSON, storageDir, password, registrationCode)
  }
}

extension NewCmix {
  public static let live = NewCmix { ndfJSON, storageDir, password, registrationCode in
    var error: NSError?
    let result = BindingsNewCmix(ndfJSON, storageDir, password, registrationCode, &error)
    if let error = error {
      throw error
    }
    return result
  }
}

extension NewCmix {
  public static let unimplemented = NewCmix(
    run: XCTUnimplemented("\(Self.self)")
  )
}
