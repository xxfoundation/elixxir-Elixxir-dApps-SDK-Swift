import Foundation
import Pulse
import XCTestDynamicOverlay

public struct Logger {
  public enum Message: Equatable {
    case error(NSError)
  }

  public var run: (Message, String, String, UInt) -> Void

  public func callAsFunction(
    _ msg: Message,
    file: String = #file,
    function: String = #function,
    line: UInt = #line
  ) {
    run(msg, file, function, line)
  }
}

extension Logger {
  public static func live() -> Logger {
    Logger { msg, file, function, line in
      switch msg {
      case .error(let error):
        LoggerStore.shared.storeMessage(
          label: "xx-messenger",
          level: .error,
          message: error.localizedDescription,
          metadata: [:],
          file: file,
          function: function,
          line: line
        )
      }
    }
  }
}

extension Logger {
  public static let unimplemented = Logger(
    run: XCTUnimplemented("\(Self.self).error")
  )
}
