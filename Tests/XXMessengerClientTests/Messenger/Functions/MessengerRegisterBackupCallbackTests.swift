import CustomDump
import XCTest
import XXClient
@testable import XXMessengerClient

final class MessengerRegisterBackupCallbackTests: XCTestCase {
  func testRegisterBackupCallback() {
    var registeredCallbacks: [UpdateBackupFunc] = []
    var didHandleData: [Data] = []
    var didCancelRegisteredCallback = 0

    var env: MessengerEnvironment = .unimplemented
    env.backupCallbacks.register = { callback in
      registeredCallbacks.append(callback)
      return Cancellable { didCancelRegisteredCallback += 1 }
    }
    let registerBackupCallback: MessengerRegisterBackupCallback = .live(env)
    let cancellable = registerBackupCallback(UpdateBackupFunc { data in
      didHandleData.append(data)
    })

    XCTAssertEqual(registeredCallbacks.count, 1)

    registeredCallbacks.forEach { callback in
      callback.handle("test".data(using: .utf8)!)
    }

    XCTAssertNoDifference(didHandleData, ["test".data(using: .utf8)!])

    cancellable.cancel()

    XCTAssertEqual(didCancelRegisteredCallback, 1)
  }
}
