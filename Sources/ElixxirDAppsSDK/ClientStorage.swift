import Bindings

public struct ClientStorage {
  public var hasStoredClient: () -> Bool
  public var createClient: () throws -> Client
  public var loadClient: () throws -> Client
  public var removeClient: () throws -> Void
}

extension ClientStorage {
  public static let defaultDirectoryURL = FileManager.default
    .urls(for: .applicationSupportDirectory, in: .userDomainMask)
    .first!
    .appendingPathComponent("xx.network.client")

  public static func live(
    environment: Environment = .mainnet,
    directoryURL: URL = defaultDirectoryURL,
    fileManager: FileManager = .default,
    generatePassword: PasswordGenerator = .live,
    passwordStorage: PasswordStorage,
    downloadNDF: NDFDownloader = .live,
    createClient: ClientCreator = .live,
    loadClient: ClientLoader = .live
  ) -> ClientStorage {
    ClientStorage(
      hasStoredClient: {
        let contents = try? fileManager.contentsOfDirectory(atPath: directoryURL.path)
        return contents.map { $0.isEmpty == false } ?? false
      },
      createClient: {
        let ndf = try downloadNDF(environment)
        let password = generatePassword()
        try passwordStorage.save(password)
        try? fileManager.removeItem(at: directoryURL)
        try? fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        try createClient(directoryURL: directoryURL, ndf: ndf, password: password)
        return try loadClient(directoryURL: directoryURL, password: password)
      },
      loadClient: {
        let password = try passwordStorage.load()
        return try loadClient(directoryURL: directoryURL, password: password)
      },
      removeClient: {
        try fileManager.removeItem(at: directoryURL)
      }
    )
  }
}

#if DEBUG
extension ClientStorage {
  public static let failing = ClientStorage(
    hasStoredClient: { false },
    createClient: {
      struct NotImplemented: Error {}
      throw NotImplemented()
    },
    loadClient: {
      struct NotImplemented: Error {}
      throw NotImplemented()
    },
    removeClient: {
      struct NotImplemented: Error {}
      throw NotImplemented()
    }
  )
}
#endif
