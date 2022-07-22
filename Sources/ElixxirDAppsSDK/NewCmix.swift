import Bindings
import XCTestDynamicOverlay

public struct NewCmix {
  public var run: (String, String, Data, String?) throws -> Void

  public func callAsFunction(
    ndfJSON: String,
    storageDir: String,
    password: Data,
    registrationCode: String?
  ) throws {
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
    if !result {
      fatalError("BindingsNewCmix returned `false` without providing error")
    }
  }
}

extension NewCmix {
  public static let unimplemented = NewCmix(
    run: XCTUnimplemented("\(Self.self)")
  )
}
