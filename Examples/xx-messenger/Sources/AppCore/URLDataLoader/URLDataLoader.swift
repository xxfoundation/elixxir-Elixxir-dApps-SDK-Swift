import Foundation
import XCTestDynamicOverlay

public struct URLDataLoader {
  public var load: (URL) throws -> Data

  public func callAsFunction(_ url: URL) throws -> Data {
    try load(url)
  }
}

extension URLDataLoader {
  public static let live = URLDataLoader { url in
    try Data(contentsOf: url)
  }
}

extension URLDataLoader {
  public static let unimplemented = URLDataLoader(
    load: XCTUnimplemented("\(Self.self)")
  )
}
