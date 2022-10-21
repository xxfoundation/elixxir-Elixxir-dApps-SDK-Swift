import Foundation
import XCTestDynamicOverlay
import XXClient
import XXMessengerClient
import XXModels

public struct ReceiveFileHandler {
  public struct ProgressError: Error {
    public init(message: String) {
      self.message = message
    }

    public var message: String
  }

  public typealias OnError = (Error) -> Void

  public var run: (@escaping OnError) -> Cancellable

  public func callAsFunction(onError: @escaping OnError) -> Cancellable {
    run(onError)
  }
}

extension ReceiveFileHandler {
  public static func live(
    messenger: Messenger,
    db: DBManagerGetDB,
    now: @escaping () -> Date
  ) -> ReceiveFileHandler {
    ReceiveFileHandler { onError in
      func receiveFile(_ file: ReceivedFile) {
        do {
          let date = now()
          try db().saveFileTransfer(XXModels.FileTransfer(
            id: file.transferId,
            contactId: file.senderId,
            name: file.name,
            type: file.type,
            data: nil,
            progress: 0,
            isIncoming: true,
            createdAt: date
          ))
          try db().saveMessage(XXModels.Message(
            senderId: file.senderId,
            recipientId: try messenger.e2e.tryGet().getContact().getId(),
            groupId: nil,
            date: date,
            status: .received,
            isUnread: false,
            text: "",
            fileTransferId: file.transferId
          ))
          try messenger.receiveFile(.init(
            transferId: file.transferId,
            callbackIntervalMS: 500
          )) { info in
            switch info {
            case .progress(let transmitted, let total):
              updateProgress(
                transferId: file.transferId,
                transmitted: transmitted,
                total: total
              )

            case .finished(let data):
              saveData(
                transferId: file.transferId,
                data: data
              )

            case .failed(.receiveError(let error)):
              onError(error)

            case .failed(.callbackError(let error)):
              onError(error)

            case .failed(.progressError(let message)):
              onError(ProgressError(message: message))
            }
          }
        } catch {
          onError(error)
        }
      }

      func updateProgress(transferId: Data, transmitted: Int, total: Int) {
        do {
          if var transfer = try db().fetchFileTransfers(.init(id: [transferId])).first {
            transfer.progress = total > 0 ? Float(transmitted) / Float(total) : 0
            try db().saveFileTransfer(transfer)
          }
        } catch {
          onError(error)
        }
      }

      func saveData(transferId: Data, data: Data) {
        do {
          if var transfer = try db().fetchFileTransfers(.init(id: [transferId])).first {
            transfer.progress = 1
            transfer.data = data
            try db().saveFileTransfer(transfer)
          }
        } catch {
          onError(error)
        }
      }

      return messenger.registerReceiveFileCallback(.init { result in
        switch result {
        case .success(let file):
          receiveFile(file)

        case .failure(let error):
          onError(error)
        }
      })
    }
  }
}

extension ReceiveFileHandler {
  public static let unimplemented = ReceiveFileHandler(
    run: XCTUnimplemented("\(Self.self)", placeholder: Cancellable {})
  )
}
