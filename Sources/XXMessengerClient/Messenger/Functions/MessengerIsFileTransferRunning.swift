import XCTestDynamicOverlay

public struct MessengerIsFileTransferRunning {
  public var run: () -> Bool

  public func callAsFunction() -> Bool {
    run()
  }
}

extension MessengerIsFileTransferRunning {
  public static func live(_ env: MessengerEnvironment) -> MessengerIsFileTransferRunning {
    MessengerIsFileTransferRunning { env.fileTransfer.get() != nil }
  }
}

extension MessengerIsFileTransferRunning {
  public static let unimplemented = MessengerIsFileTransferRunning(
    run: XCTUnimplemented("\(Self.self)")
  )
}
