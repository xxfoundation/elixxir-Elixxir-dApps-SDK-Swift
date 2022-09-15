import Bindings
import XCTestDynamicOverlay

public struct CMixGetRunningProcesses {
  public var run: () throws -> [String]

  public func callAsFunction() throws -> [String] {
    try run()
  }
}

extension CMixGetRunningProcesses {
  public static func live(_ bindingsCMix: BindingsCmix) -> CMixGetRunningProcesses {
    CMixGetRunningProcesses {
      let data = try bindingsCMix.getRunningProcesses()
      return try JSONDecoder().decode([String].self, from: data)
    }
  }
}

extension CMixGetRunningProcesses {
  public static let unimplemented = CMixGetRunningProcesses(
    run: XCTUnimplemented("\(Self.self)")
  )
}
