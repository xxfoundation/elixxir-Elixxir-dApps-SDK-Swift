import CustomDump
import Foundation

struct StringData: Equatable, CustomDumpStringConvertible {
  var data: Data

  var customDumpDescription: String {
    if let string = String(data: data, encoding: .utf8) {
      return #"Data(string: "\#(string)", encoding: .utf8)"#
    } else {
      return data.customDumpDescription
    }
  }
}
