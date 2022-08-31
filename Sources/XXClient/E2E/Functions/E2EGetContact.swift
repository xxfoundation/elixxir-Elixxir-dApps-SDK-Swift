import Bindings
import XCTestDynamicOverlay

public struct E2EGetContact {
  public var run: () -> Contact

  public func callAsFunction() -> Contact {
    run()
  }
}

extension E2EGetContact {
  public static func live(_ bindingsE2E: BindingsE2e) -> E2EGetContact {
    E2EGetContact {
      guard let data = bindingsE2E.getContact() else {
        fatalError("BindingsE2e.getContact returned `nil`")
      }
      return Contact.live(data)
    }
  }
}

extension E2EGetContact {
  public static let unimplemented = E2EGetContact(
    run: XCTUnimplemented(
      "\(Self.self)",
      placeholder: .unimplemented("unimplemented".data(using: .utf8)!)
    )
  )
}
