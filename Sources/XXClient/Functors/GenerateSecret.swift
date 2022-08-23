import Bindings
import XCTestDynamicOverlay

public struct GenerateSecret {
  public var run: (Int) -> Data

  public func callAsFunction(numBytes: Int = 32) -> Data {
    run(numBytes)
  }
}

extension GenerateSecret {
  public static let live = GenerateSecret { numBytes in
    guard let secret = BindingsGenerateSecret(numBytes) else {
      fatalError("BindingsGenerateSecret returned `nil`")
    }
    return secret
  }
}

extension GenerateSecret {
  public static let unimplemented = GenerateSecret(
    run: XCTUnimplemented("\(Self.self)", placeholder: "unimplemented".data(using: .utf8)!)
  )
}
