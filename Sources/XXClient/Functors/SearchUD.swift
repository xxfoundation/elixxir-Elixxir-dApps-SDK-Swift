import Bindings
import XCTestDynamicOverlay

public struct SearchUD {
  public var run: (Int, Data, [Fact], Data, UdSearchCallback) throws -> SingleUseSendReport

  public func callAsFunction(
    e2eId: Int,
    udContact: Data,
    facts: [Fact],
    singleRequestParamsJSON: Data = GetSingleUseParams.liveDefault(),
    callback: UdSearchCallback
  ) throws -> SingleUseSendReport {
    try run(e2eId, udContact, facts, singleRequestParamsJSON, callback)
  }
}

extension SearchUD {
  public static let live = SearchUD {
    e2eId, udContact, facts, singleRequestParamsJSON, callback in

    var error: NSError?
    let reportData = BindingsSearchUD(
      e2eId,
      udContact,
      callback.makeBindingsUdSearchCallback(),
      try facts.encode(),
      singleRequestParamsJSON,
      &error
    )
    if let error = error {
      throw error
    }
    guard let reportData = reportData else {
      fatalError("BindingsSearchUD returned `nil` without providing error")
    }
    return try SingleUseSendReport.decode(reportData)
  }
}

extension SearchUD {
  public static let unimplemented = SearchUD(
    run: XCTUnimplemented("\(Self.self)")
  )
}

