import Bindings
import XCTestDynamicOverlay

public struct CmixManagerLoad {
  public var run: () throws -> Cmix

  public func callAsFunction() throws -> Cmix {
    try run()
  }
}

extension CmixManagerLoad {
  public static func live(
    directoryPath: String,
    passwordStorage: PasswordStorage,
    getCmixParams: GetCmixParams,
    loadCmix: LoadCmix
  ) -> CmixManagerLoad {
    CmixManagerLoad {
      try loadCmix(
        storageDir: directoryPath,
        password: passwordStorage.load(),
        cmixParamsJSON: getCmixParams()
      )
    }
  }
}

extension CmixManagerLoad {
  public static let unimplemented = CmixManagerLoad(
    run: XCTUnimplemented("\(Self.self)")
  )
}
