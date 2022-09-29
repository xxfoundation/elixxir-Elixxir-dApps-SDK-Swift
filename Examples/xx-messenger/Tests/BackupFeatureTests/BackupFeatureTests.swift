import ComposableArchitecture
import XCTest
@testable import BackupFeature

final class BackupFeatureTests: XCTestCase {
  func testStart() {
    let store = TestStore(
      initialState: BackupState(),
      reducer: backupReducer,
      environment: .unimplemented
    )

    store.send(.start)
  }
}
