import Bindings

public struct FileTransfer {
  public var closeSend: FileTransferCloseSend
  public var maxFileNameLen: FileTransferMaxFilenameLen
  public var maxFileSize: FileTransferMaxFileSize
  public var maxFileTypeLen: FileTransferMaxFileTypeLen
  public var maxPreviewSize: FileTransferMaxPreviewSize
  public var receive: FileTransferReceive
  public var registerReceivedProgressCallback: FileTransferRegisterReceivedProgressCallback
  public var registerSentProgressCallback: FileTransferRegisterSentProgressCallback
  public var send: FileTransferSend
}

extension FileTransfer {
  public static func live(_ bindingsFileTransfer: BindingsFileTransfer) -> FileTransfer {
    FileTransfer(
      closeSend: .live(bindingsFileTransfer),
      maxFileNameLen: .live(bindingsFileTransfer),
      maxFileSize: .live(bindingsFileTransfer),
      maxFileTypeLen: .live(bindingsFileTransfer),
      maxPreviewSize: .live(bindingsFileTransfer),
      receive: .live(bindingsFileTransfer),
      registerReceivedProgressCallback: .live(bindingsFileTransfer),
      registerSentProgressCallback: .live(bindingsFileTransfer),
      send: .live(bindingsFileTransfer)
    )
  }
}

extension FileTransfer {
  public static let unimplemented = FileTransfer(
    closeSend: .unimplemented,
    maxFileNameLen: .unimplemented,
    maxFileSize: .unimplemented,
    maxFileTypeLen: .unimplemented,
    maxPreviewSize: .unimplemented,
    receive: .unimplemented,
    registerReceivedProgressCallback: .unimplemented,
    registerSentProgressCallback: .unimplemented,
    send: .unimplemented
  )
}
