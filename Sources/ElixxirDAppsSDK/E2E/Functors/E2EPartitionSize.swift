import Bindings
import XCTestDynamicOverlay

public struct E2EPartitionSize {
  public var first: () -> Int
  public var second: () -> Int
  public var atIndex: (Int) -> Int

  subscript(payloadIndex payloadIndex: Int) -> Int {
    atIndex(payloadIndex)
  }
}

extension E2EPartitionSize {
  public static func live(_ bindingsE2E: BindingsE2e) -> E2EPartitionSize {
    E2EPartitionSize(
      first: bindingsE2E.firstPartitionSize,
      second: bindingsE2E.secondPartitionSize,
      atIndex: bindingsE2E.partitionSize(_:)
    )
  }
}

extension E2EPartitionSize {
  public static let unimplemented = E2EPartitionSize(
    first: XCTUnimplemented("\(Self.self).first"),
    second: XCTUnimplemented("\(Self.self).second"),
    atIndex: XCTUnimplemented("\(Self.self).atIndex")
  )
}
