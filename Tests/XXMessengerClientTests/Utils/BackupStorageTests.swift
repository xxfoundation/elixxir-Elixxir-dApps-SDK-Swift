import CustomDump
import XCTest
@testable import XXMessengerClient

final class BackupStorageTests: XCTestCase {
  func testStorage() throws {
    var actions: [Action]!

    var now: Date = .init(0)
    let path = "backup-path"
    let fileData = "file-data".data(using: .utf8)!
    let fileDate = Date(123)
    var fileManager = MessengerFileManager.unimplemented
    fileManager.loadFile = { path in
      actions.append(.didLoadFile(path))
      return fileData
    }
    fileManager.modifiedTime = { path in
      actions.append(.didGetModifiedTime(path))
      return fileDate
    }
    fileManager.saveFile = { path, data in
      actions.append(.didSaveFile(path, data))
    }
    fileManager.removeItem = { path in
      actions.append(.didRemoveItem(path))
    }
    actions = []
    let storage: BackupStorage = .onDisk(
      now: { now },
      fileManager: fileManager,
      path: path
    )

    XCTAssertNoDifference(
      storage.stored(),
      BackupStorage.Backup(date: fileDate, data: fileData)
    )
    XCTAssertNoDifference(actions, [
      .didLoadFile(path),
      .didGetModifiedTime(path),
    ])

    actions = []
    let observerA = storage.observe { backup in
      actions.append(.didObserve("A", backup))
    }

    XCTAssertNoDifference(actions, [])
    XCTAssertNoDifference(
      storage.stored(),
      BackupStorage.Backup(date: fileDate, data: fileData)
    )

    actions = []
    now = .init(1)
    let data1 = "data-1".data(using: .utf8)!
    try storage.store(data1)

    XCTAssertNoDifference(
      storage.stored(),
      BackupStorage.Backup(date: .init(1), data: data1)
    )
    XCTAssertNoDifference(actions, [
      .didObserve("A", .init(date: .init(1), data: data1)),
      .didSaveFile(path, data1),
    ])

    actions = []
    let observerB = storage.observe { backup in
      actions.append(.didObserve("B", backup))
    }

    XCTAssertNoDifference(actions, [])

    actions = []
    now = .init(2)
    observerA.cancel()
    let data2 = "data-2".data(using: .utf8)!
    try storage.store(data2)

    XCTAssertNoDifference(actions, [
      .didObserve("B", .init(date: .init(2), data: data2)),
      .didSaveFile(path, data2),
    ])

    actions = []
    now = .init(3)
    try storage.remove()

    XCTAssertNoDifference(actions, [
      .didObserve("B", nil),
      .didRemoveItem(path),
    ])

    actions = []
    now = .init(4)
    observerB.cancel()
    let data3 = "data-3".data(using: .utf8)!
    try storage.store(data3)

    XCTAssertNoDifference(actions, [
      .didSaveFile(path, data3),
    ])
  }
}

private extension Date {
  init(_ timeIntervalSince1970: TimeInterval) {
    self.init(timeIntervalSince1970: timeIntervalSince1970)
  }
}

private enum Action: Equatable {
  case didLoadFile(String)
  case didGetModifiedTime(String)
  case didObserve(String, BackupStorage.Backup?)
  case didSaveFile(String, Data)
  case didRemoveItem(String)
}
