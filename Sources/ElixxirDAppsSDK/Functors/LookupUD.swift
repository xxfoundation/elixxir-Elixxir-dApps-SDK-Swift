import Bindings
import XCTestDynamicOverlay

public struct LookupUD {
  public var run: (Int, Data, Data, Data, UdLookupCallback) throws -> SingleUseSendReport

  public func callAsFunction(
    e2eId: Int,
    udContact: Data,
    udId: Data,
    singleRequestParamsJSON: Data = GetSingleUseParams.liveDefault(),
    callback: UdLookupCallback
  ) throws -> SingleUseSendReport {
    try run(e2eId, udContact, udId, singleRequestParamsJSON, callback)
  }
}

extension LookupUD {
  public static let live = LookupUD {
    e2eId, udContact, udId, singleRequestParamsJSON, callback in

    var error: NSError?
    let reportData = BindingsLookupUD(
      e2eId,
      udContact,
      callback.makeBindingsUdLookupCallback(),
      udId,
      singleRequestParamsJSON,
      &error
    )
    if let error = error {
      throw error
    }
    guard let reportData = reportData else {
      fatalError("BindingsLookupUD returned `nil` without providing error")
    }
    return try SingleUseSendReport.decode(reportData)
  }
}

extension LookupUD {
  public static let unimplemented = LookupUD(
    run: XCTUnimplemented("\(Self.self)")
  )
}
