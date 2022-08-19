import Bindings
import XCTestDynamicOverlay

public struct GroupRequest {
  public init(handle: @escaping (Group) -> Void) {
    self.handle = handle
  }

  public var handle: (Group) -> Void
}

extension GroupRequest {
  public static let unimplemented = GroupRequest(
    handle: XCTUnimplemented("\(Self.self)")
  )
}

extension GroupRequest {
  func makeBindingsGroupRequest() -> BindingsGroupRequestProtocol {
    class CallbackObject: NSObject, BindingsGroupRequestProtocol {
      init(_ callback: GroupRequest) {
        self.callback = callback
      }

      let callback: GroupRequest

      func callback(_ g: BindingsGroup?) {
        guard let bindingsGroup = g else {
          fatalError("BindingsGroupRequest.handle received `nil` group")
        }
        callback.handle(.live(bindingsGroup))
      }
    }

    return CallbackObject(self)
  }
}
