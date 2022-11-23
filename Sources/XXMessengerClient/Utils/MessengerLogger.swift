import Foundation
import Logging
import XCTestDynamicOverlay

public struct MessengerLogger {
  public struct Log: Equatable {
    public init(level: Logger.Level, message: String) {
      self.level = level
      self.message = message
    }

    public var level: Logger.Level
    public var message: String
  }

  public var run: (Log, String, String, UInt) -> Void

  public func callAsFunction(
    _ item: Log,
    file: String = #fileID,
    function: String = #function,
    line: UInt = #line
  ) {
    run(item, file, function, line)
  }
}

extension MessengerLogger {
  public static func live(
    logger: Logger = Logger(label: "xx.network.MessengerClient")
  ) -> MessengerLogger {
    MessengerLogger { item, file, function, line in
      logger.log(
        level: item.level,
        .init(stringLiteral: item.message),
        file: file,
        function: function,
        line: line
      )
    }
  }
}

extension MessengerLogger {
  public static let unimplemented = MessengerLogger(
    run: XCTUnimplemented("\(Self.self)")
  )
}

extension MessengerLogger.Log {
  static func parse(_ string: String) -> MessengerLogger.Log {
    let level: Logger.Level
    let message: String
    let pattern = #"^([A-Z]+)( \d{4}/\d{2}/\d{2})?( \d{1,2}:\d{2}:\d{2}\.\d+)? (.*)"#
    let regex = try! NSRegularExpression(
      pattern: pattern,
      options: .dotMatchesLineSeparators
    )
    let stringRange = NSRange(location: 0, length: string.utf16.count)
    if let match = regex.firstMatch(in: string, range: stringRange) {
      var groups: [Int: String] = [:]
      for rangeIndex in 1..<match.numberOfRanges {
        let nsRange = match.range(at: rangeIndex)
        if !NSEqualRanges(nsRange, NSMakeRange(NSNotFound, 0)) {
          let group = (string as NSString).substring(with: nsRange)
          groups[rangeIndex] = group
        }
      }
      level = MessengerLogger.Log.level(form: groups[1])
      message = groups[4] ?? string
    } else {
      level = .notice
      message = string
    }
    return MessengerLogger.Log(level: level, message: message)
  }

  static func level(form string: String?) -> Logger.Level {
    switch string {
    case "TRACE": return .trace
    case "DEBUG": return .debug
    case "INFO": return .info
    case "WARN": return .warning
    case "ERROR": return .error
    case "CRITICAL": return .critical
    case "FATAL": return .critical
    default: return .notice
    }
  }
}
