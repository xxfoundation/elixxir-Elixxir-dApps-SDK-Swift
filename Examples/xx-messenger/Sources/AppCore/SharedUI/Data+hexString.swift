import Foundation

extension Data {
  public func hexString(bytesSeparator: String = " ") -> String {
    map { String(format: "%02hhx\(bytesSeparator)", $0) }.joined()
  }
}
