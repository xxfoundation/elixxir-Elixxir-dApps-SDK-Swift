import Bindings
import XCTestDynamicOverlay

public struct SingleUseResponse {
  public init(handle: @escaping (Result<SingleUseResponseReport, NSError>) -> Void) {
    self.handle = handle
  }

  public var handle: (Result<SingleUseResponseReport, NSError>) -> Void
}

extension SingleUseResponse {
  public static let unimplemented = SingleUseResponse(
    handle: XCTUnimplemented("\(Self.self)")
  )
}

extension SingleUseResponse {
  func makeBindingsSingleUseResponse() -> BindingsSingleUseResponseProtocol {
    class Response: NSObject, BindingsSingleUseResponseProtocol {
      init(_ callback: SingleUseResponse) {
        self.callback = callback
      }

      let callback: SingleUseResponse

      func callback(_ responseReport: Data?, err: Error?) {
        if let error = err {
          callback.handle(.failure(error as NSError))
        } else if let reportData = responseReport {
          do {
            callback.handle(.success(try SingleUseResponseReport.decode(reportData)))
          } catch {
            callback.handle(.failure(error as NSError))
          }
        } else {
          fatalError("BindingsSingleUseResponse received `nil` responseReport and `nil` err")
        }
      }
    }

    return Response(self)
  }
}
