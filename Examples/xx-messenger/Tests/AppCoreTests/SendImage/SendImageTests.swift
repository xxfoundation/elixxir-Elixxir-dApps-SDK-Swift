import CustomDump
import XCTest
import XXClient
import XXMessengerClient
import XXModels
@testable import AppCore

final class SendImageTests: XCTestCase {
  func testSend() {
    let image = "image-data".data(using: .utf8)!
    let recipientId = "recipient-id".data(using: .utf8)!
    let myContactId = "my-contact-id".data(using: .utf8)!
    let transferId = "transfer-id".data(using: .utf8)!
    let currentDate = Date(timeIntervalSince1970: 123)

    var actions: [Action] = []
    var sendFileCallback: MessengerSendFile.Callback?

    var messenger: Messenger = .unimplemented
    messenger.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getContact.run = {
        var contact: XXClient.Contact = .unimplemented(Data())
        contact.getIdFromContact.run = { _ in myContactId }
        return contact
      }
      return e2e
    }
    messenger.sendFile.run = { params, callback in
      actions.append(.didSendFile(params))
      sendFileCallback = callback
      return transferId
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
        return [.stub(withProgress: 0)]
      }
      return db
    }
    let send: SendImage = .live(messenger: messenger, db: db, now: { currentDate })

    actions = []
    send(
      image,
      to: recipientId,
      onError: { error in
        actions.append(.didFail(error as NSError))
      },
      completion: {
        actions.append(.didComplete)
      }
    )

    XCTAssertNoDifference(actions, [
      .didSendFile(.init(
        file: .init(
          name: "image.jpg",
          type: "image",
          preview: nil,
          contents: image
        ),
        recipientId: recipientId,
        retry: 2,
        callbackIntervalMS: 500
      )),
      .didSaveFileTransfer(.init(
        id: transferId,
        contactId: myContactId,
        name: "image.jpg",
        type: "image",
        data: image,
        progress: 0,
        isIncoming: false,
        createdAt: currentDate
      )),
      .didSaveMessage(.init(
        senderId: myContactId,
        recipientId: recipientId,
        groupId: nil,
        date: currentDate,
        status: .sent,
        isUnread: false,
        text: "",
        fileTransferId: transferId
      )),
    ])

    actions = []
    let sendError = NSError(domain: "send-error", code: 1)
    sendFileCallback?(.failed(id: transferId, .error(sendError)))

    XCTAssertNoDifference(actions, [
      .didFail(sendError),
    ])

    actions = []
    let closeError = NSError(domain: "close-error", code: 2)
    sendFileCallback?(.failed(id: transferId, .close(closeError)))

    XCTAssertNoDifference(actions, [
      .didFail(closeError),
    ])

    actions = []
    let progressError = "progress-error"
    sendFileCallback?(.failed(id: transferId, .progressError(progressError)))

    XCTAssertNoDifference(actions, [
      .didFail(SendImage.ProgressError(message: progressError) as NSError),
    ])

    actions = []
    sendFileCallback?(.progress(id: transferId, transmitted: 1, total: 2))

    XCTAssertNoDifference(actions, [
      .didFetchFileTransfers(.init(id: [transferId])),
      .didSaveFileTransfer(.stub(withProgress: 0.5)),
    ])

    actions = []
    sendFileCallback?(.finished(id: transferId))

    XCTAssertNoDifference(actions, [
      .didFetchFileTransfers(.init(id: [transferId])),
      .didSaveFileTransfer(.stub(withProgress: 1)),
    ])
  }
}

private enum Action: Equatable {
  case didFail(NSError)
  case didComplete
  case didSendFile(MessengerSendFile.Params)
  case didSaveFileTransfer(XXModels.FileTransfer)
  case didSaveMessage(XXModels.Message)
  case didFetchFileTransfers(XXModels.FileTransfer.Query)
}

private extension XXModels.FileTransfer {
  static func stub(withProgress progress: Float) -> XXModels.FileTransfer {
    XXModels.FileTransfer(
      id: Data(),
      contactId: Data(),
      name: "",
      type: "",
      data: nil,
      progress: progress,
      isIncoming: false,
      createdAt: Date(timeIntervalSince1970: 0)
    )
  }
}
