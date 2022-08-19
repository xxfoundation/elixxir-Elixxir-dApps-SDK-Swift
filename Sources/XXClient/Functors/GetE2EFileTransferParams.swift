import Bindings
import XCTestDynamicOverlay

public struct GetE2EFileTransferParams {
  public var run: () -> Data

  public func callAsFunction() -> Data {
    run()
  }
}

extension GetE2EFileTransferParams {
  public static let liveDefault = GetE2EFileTransferParams {
    guard let data = BindingsGetDefaultE2eFileTransferParams() else {
      fatalError("BindingsGetDefaultE2eFileTransferParams returned `nil`")
    }
    return data
  }
}

extension GetE2EFileTransferParams {
  public static let unimplemented = GetE2EFileTransferParams(
    run: XCTUnimplemented("\(Self.self)")
  )
}

