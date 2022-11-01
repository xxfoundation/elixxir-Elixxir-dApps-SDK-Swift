import Foundation
import XCTestDynamicOverlay
import XXClient
import XXMessengerClient
import XXModels

public struct SendImage {
  public typealias OnError = (Error) -> Void
  public typealias Completion = () -> Void

  public var run: (Data, Data, @escaping OnError, @escaping Completion) -> Void

  public func callAsFunction(
    _ image: Data,
    to recipientId: Data,
    onError: @escaping OnError,
    completion: @escaping Completion
  ) {
    run(image, recipientId, onError, completion)
  }
}

extension SendImage {
  public static func live(
    messenger: Messenger,
    db: DBManagerGetDB,
    now: @escaping () -> Date
  ) -> SendImage {
    SendImage { image, recipientId, onError, completion in
      func updateProgress(transferId: Data, progress: Float) {
        do {
          if var transfer = try db().fetchFileTransfers(.init(id: [transferId])).first {
            transfer.progress = progress
            try db().saveFileTransfer(transfer)
          }
        } catch {
          onError(error)
        }
      }

      let file = FileSend(
        name: "image.jpg",
        type: "image",
        preview: nil,
        contents: image
      )
      let params = MessengerSendFile.Params(
        file: file,
        recipientId: recipientId,
        retry: 2,
        callbackIntervalMS: 500
      )
      do {
        let date = now()
        let myContactId = try messenger.e2e.tryGet().getContact().getId()
        let transferId = try messenger.sendFile(params) { info in
          switch info {
          case .progress(let transferId, let transmitted, let total):
            updateProgress(
              transferId: transferId,
              progress: total > 0 ? Float(transmitted) / Float(total) : 0
            )

          case .finished(let transferId):
            updateProgress(
              transferId: transferId,
              progress: 1
            )

          case .failed(_, .callback(let error)):
            onError(error)

          case .failed(_, .close(let error)):
            onError(error)
          }
        }
        try db().saveFileTransfer(XXModels.FileTransfer(
          id: transferId,
          contactId: myContactId,
          name: file.name,
          type: file.type,
          data: image,
          progress: 0,
          isIncoming: false,
          createdAt: date
        ))
        try db().saveMessage(XXModels.Message(
          senderId: myContactId,
          recipientId: recipientId,
          groupId: nil,
          date: date,
          status: .sent,
          isUnread: false,
          text: "",
          fileTransferId: transferId
        ))
      } catch {
        onError(error)
      }
    }
  }
}

extension SendImage {
  public static let unimplemented = SendImage(
    run: XCTUnimplemented("\(Self.self)")
  )
}
