import Foundation
import XCTestDynamicOverlay
import XXClient

public struct GroupRequestCallbacksRegistry {
  public var register: (GroupRequest) -> Cancellable
  public var registered: () -> GroupRequest
}

extension GroupRequestCallbacksRegistry {
  public static func live() -> GroupRequestCallbacksRegistry {
    class Registry {
      var items: [UUID: GroupRequest] = [:]
    }
    let registry = Registry()
    return GroupRequestCallbacksRegistry(
      register: { groupRequest in
        let id = UUID()
        registry.items[id] = groupRequest
        return Cancellable { registry.items[id] = nil }
      },
      registered: {
        GroupRequest { group in
          registry.items.values.forEach { $0.handle(group) }
        }
      }
    )
  }
}

extension GroupRequestCallbacksRegistry {
  public static let unimplemented = GroupRequestCallbacksRegistry(
    register: XCTestDynamicOverlay.unimplemented(
      "\(Self.self).register",
      placeholder: Cancellable {}
    ),
    registered: XCTestDynamicOverlay.unimplemented(
      "\(Self.self).registered",
      placeholder: .unimplemented
    )
  )
}
