import Bindings
import XCTestDynamicOverlay

public struct LookupUD {
  public var run: (Int, Contact, Data, Data, UdLookupCallback) throws -> SingleUseSendReport

  public func callAsFunction(
    e2eId: Int,
    udContact: Contact,
    lookupId: Data,
    singleRequestParamsJSON: Data = GetSingleUseParams.liveDefault(),
    callback: UdLookupCallback
  ) throws -> SingleUseSendReport {
    try run(e2eId, udContact, lookupId, singleRequestParamsJSON, callback)
  }
}

extension LookupUD {
  public static let live = LookupUD {
    e2eId, udContact, lookupId, singleRequestParamsJSON, callback in

    var error: NSError?
    let reportData = BindingsLookupUD(
      e2eId,
      udContact.data,
      callback.makeBindingsUdLookupCallback(),
      lookupId,
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
