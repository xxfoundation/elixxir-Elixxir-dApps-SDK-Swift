import Bindings
import XCTestDynamicOverlay

public struct GetFileTransferParams {
  public var run: () -> Data

  public func callAsFunction() -> Data {
    run()
  }
}

extension GetFileTransferParams {
  public static let liveDefault = GetFileTransferParams {
    guard let data = BindingsGetDefaultFileTransferParams() else {
      fatalError("BindingsGetDefaultFileTransferParams returned `nil`")
    }
    return data
  }
}

extension GetFileTransferParams {
  public static let unimplemented = GetFileTransferParams(
    run: XCTUnimplemented("\(Self.self)", placeholder: "unimplemented".data(using: .utf8)!)
  )
}

