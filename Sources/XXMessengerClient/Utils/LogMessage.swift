import Foundation
import Logging

struct LogMessage: Equatable {
  var level: Logger.Level
  var text: String
}

extension LogMessage {
  static func parse(_ string: String) -> LogMessage? {
    let level: Logger.Level
    let text: String
    let pattern = #"([A-Z]+) (.*)"#
    let regex = try! NSRegularExpression(pattern: pattern)
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
      level = .fromString(groups[1])
      text = groups[2] ?? string
    } else {
      level = .notice
      text = string
    }
    return LogMessage(level: level, text: text)
  }
}

private extension Logger.Level {
  static func fromString(_ string: String?) -> Logger.Level {
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
