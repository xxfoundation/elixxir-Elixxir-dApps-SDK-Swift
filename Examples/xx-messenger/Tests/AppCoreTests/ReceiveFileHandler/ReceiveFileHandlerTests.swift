import CustomDump
import XCTest
import XXMessengerClient
import XXClient
import XXModels
@testable import AppCore

final class ReceiveFileHandlerTests: XCTestCase {
  func testReceiveFile() {
    let currentDate = Date(timeIntervalSince1970: 123)
    let myContactId = "my-contact-id".data(using: .utf8)!
    let receivedFile = ReceivedFile.stub()

    var actions: [Action] = []
    var receiveFileCallback: ReceiveFileCallback?
    var receivingFileCallback: MessengerReceiveFile.Callback?

    var messenger: Messenger = .unimplemented
    messenger.registerReceiveFileCallback.run = { callback in
      actions.append(.didRegisterReceiveFileCallback)
      receiveFileCallback = callback
      return Cancellable { actions.append(.didCancelReceiveFileCallback) }
    }
    messenger.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getContact.run = {
        var contact: XXClient.Contact = .unimplemented(Data())
        contact.getIdFromContact.run = { _ in myContactId }
        return contact
      }
      return e2e
    }
    messenger.receiveFile.run = { params, callback in
      actions.append(.didReceiveFile(params))
      receivingFileCallback = callback
    }

    var db: DBManagerGetDB = .unimplemented
    db.run = {
      var db: Database = .unimplemented
      db.saveFileTransfer.run = { model in
        actions.append(.didSaveFileTransfer(model))
        return model
      }
      db.saveMessage.run = { model in
        actions.append(.didSaveMessage(model))
        return model
      }
      db.fetchFileTransfers.run = { query in
        actions.append(.didFetchFileTransfers(query))
        return [
          FileTransfer(
            id: receivedFile.transferId,
            contactId: receivedFile.senderId,
            name: receivedFile.name,
            type: receivedFile.type,
            data: nil,
            progress: 0,
            isIncoming: true,
            createdAt: currentDate
          )
        ]
      }
      return db
    }

    let handler = ReceiveFileHandler.live(
      messenger: messenger,
      db: db,
      now: { currentDate }
    )

    XCTAssertNoDifference(actions, [])

    actions = []
    let cancellable = handler(onError: { error in
      actions.append(.didCatchError(error as NSError))
    })

    XCTAssertNoDifference(actions, [
      .didRegisterReceiveFileCallback
    ])

    actions = []
    let error = NSError(domain: "receive-file", code: 1)
    receiveFileCallback?.handle(.failure(error))

    XCTAssertNoDifference(actions, [
      .didCatchError(error)
    ])

    actions = []
    receiveFileCallback?.handle(.success(receivedFile))

    XCTAssertNoDifference(actions, [
      .didSaveFileTransfer(FileTransfer(
        id: receivedFile.transferId,
        contactId: receivedFile.senderId,
        name: receivedFile.name,
        type: receivedFile.type,
        data: nil,
        progress: 0,
        isIncoming: true,
        createdAt: currentDate
      )),
      .didSaveMessage(Message(
        networkId: nil,
        senderId: receivedFile.senderId,
        recipientId: myContactId,
        groupId: nil,
        date: currentDate,
        status: .received,
        isUnread: false,
        text: "",
        replyMessageId: nil,
        roundURL: nil,
        fileTransferId: receivedFile.transferId
      )),
      .didReceiveFile(MessengerReceiveFile.Params(
        transferId: receivedFile.transferId,
        callbackIntervalMS: 500
      )),
    ])

    actions = []
    let receivingFileError = NSError(domain: "receiving-file", code: 2)
    receivingFileCallback?(.failed(.receiveError(receivingFileError)))

    XCTAssertNoDifference(actions, [
      .didCatchError(receivingFileError)
    ])

    actions = []
    let receivingFileCallbackError = NSError(domain: "receiving-file-callback", code: 3)
    receivingFileCallback?(.failed(.callbackError(receivingFileCallbackError)))

    XCTAssertNoDifference(actions, [
      .didCatchError(receivingFileCallbackError)
    ])

    actions = []
    receivingFileCallback?(.progress(transmitted: 1, total: 2))

    XCTAssertNoDifference(actions, [
      .didFetchFileTransfers(.init(id: [receivedFile.transferId])),
      .didSaveFileTransfer(FileTransfer(
        id: receivedFile.transferId,
        contactId: receivedFile.senderId,
        name: receivedFile.name,
        type: receivedFile.type,
        data: nil,
        progress: 0.5,
        isIncoming: true,
        createdAt: currentDate
      )),
    ])

    actions = []
    let fileData = "file-data".data(using: .utf8)!
    receivingFileCallback?(.finished(fileData))

    XCTAssertNoDifference(actions, [
      .didFetchFileTransfers(.init(id: [receivedFile.transferId])),
      .didSaveFileTransfer(FileTransfer(
        id: receivedFile.transferId,
        contactId: receivedFile.senderId,
        name: receivedFile.name,
        type: receivedFile.type,
        data: fileData,
        progress: 1,
        isIncoming: true,
        createdAt: currentDate
      )),
    ])

    actions = []
    cancellable.cancel()

    XCTAssertNoDifference(actions, [
      .didCancelReceiveFileCallback
    ])
  }
}

private enum Action: Equatable {
  case didRegisterReceiveFileCallback
  case didCancelReceiveFileCallback
  case didCatchError(NSError)
  case didSaveFileTransfer(XXModels.FileTransfer)
  case didSaveMessage(XXModels.Message)
  case didReceiveFile(MessengerReceiveFile.Params)
  case didFetchFileTransfers(XXModels.FileTransfer.Query)
}

private extension ReceivedFile {
  static func stub() -> ReceivedFile {
    ReceivedFile(
      transferId: "received-file-transferId".data(using: .utf8)!,
      senderId: "received-file-senderId".data(using: .utf8)!,
      preview: "received-file-preview".data(using: .utf8)!,
      name: "received-file-name",
      type: "received-file-type",
      size: 1234
    )
  }
}
