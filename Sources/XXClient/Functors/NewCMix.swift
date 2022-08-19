import Bindings
import XCTestDynamicOverlay

public struct NewCMix {
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

extension NewCMix {
  public static let live = NewCMix { ndfJSON, storageDir, password, registrationCode in
    var error: NSError?
    let result = BindingsNewCmix(ndfJSON, storageDir, password, registrationCode, &error)
    if let error = error {
      throw error
    }
    if !result {
      fatalError("BindingsNewCMix returned `false` without providing error")
    }
  }
}

extension NewCMix {
  public static let unimplemented = NewCMix(
    run: XCTUnimplemented("\(Self.self)")
  )
}
