import Bindings
import XCTestDynamicOverlay

public struct LookupUD {
  public struct Params: Equatable {
    public init(
      e2eId: Int,
      udContact: Contact,
      lookupId: Data,
      singleRequestParamsJSON: Data = GetSingleUseParams.liveDefault()
    ) {
      self.e2eId = e2eId
      self.udContact = udContact
      self.lookupId = lookupId
      self.singleRequestParamsJSON = singleRequestParamsJSON
    }

    public var e2eId: Int
    public var udContact: Contact
    public var lookupId: Data
    public var singleRequestParamsJSON: Data
  }

  public var run: (Params, UdLookupCallback) throws -> SingleUseSendReport

  public func callAsFunction(
    params: Params,
    callback: UdLookupCallback
  ) throws -> SingleUseSendReport {
    try run(params, callback)
  }
}

extension LookupUD {
  public static let live = LookupUD { params, callback in

    var error: NSError?
    let reportData = BindingsLookupUD(
      params.e2eId,
      params.udContact.data,
      callback.makeBindingsUdLookupCallback(),
      params.lookupId,
      params.singleRequestParamsJSON,
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
