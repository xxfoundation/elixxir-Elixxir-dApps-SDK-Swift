import CustomDump
import XCTest
@testable import XXMessengerClient

final class BackupStorageTests: XCTestCase {
  func testStorage() {
    var now: Date = .init(0)
    let storage: BackupStorage = .live(
      now: { now }
    )

    var didObserveA: [BackupStorage.Backup?] = []
    let observerA = storage.observe { backup in
      didObserveA.append(backup)
    }

    XCTAssertNoDifference(didObserveA, [nil])

    now = .init(1)
    didObserveA = []
    let data1 = "data-1".data(using: .utf8)!
    storage.store(data1)

    XCTAssertNoDifference(didObserveA, [.init(date: .init(1), data: data1)])

    now = .init(2)
    didObserveA = []
    var didObserveB: [BackupStorage.Backup?] = []
    let observerB = storage.observe { backup in
      didObserveB.append(backup)
    }

    XCTAssertNoDifference(didObserveA, [])
    XCTAssertNoDifference(didObserveB, [.init(date: .init(1), data: data1)])

    now = .init(3)
    didObserveA = []
    didObserveB = []
    let data2 = "data-2".data(using: .utf8)!
    storage.store(data2)

    XCTAssertNoDifference(didObserveA, [.init(date: .init(3), data: data2)])
    XCTAssertNoDifference(didObserveB, [.init(date: .init(3), data: data2)])

    now = .init(4)
    didObserveA = []
    didObserveB = []
    observerA.cancel()
    storage.remove()

    XCTAssertNoDifference(didObserveA, [])
    XCTAssertNoDifference(didObserveB, [nil])

    now = .init(5)
    didObserveA = []
    didObserveB = []
    observerB.cancel()
    let data3 = "data-3".data(using: .utf8)!
    storage.store(data3)

    XCTAssertNoDifference(didObserveA, [])
    XCTAssertNoDifference(didObserveB, [])
  }
}

private extension Date {
  init(_ timeIntervalSince1970: TimeInterval) {
    self.init(timeIntervalSince1970: timeIntervalSince1970)
  }
}
