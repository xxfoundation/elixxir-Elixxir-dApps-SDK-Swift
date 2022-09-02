import KeychainAccess
import XXClient

extension PasswordStorage {
  public static let keychain: PasswordStorage = {
    let keychain = KeychainAccess.Keychain(service: "xx.network.client.messenger")
    let key = "password"
    return PasswordStorage(
      save: { password in
        keychain[data: key] = password
      },
      load: {
        guard let password = keychain[data: key] else {
          throw MissingPasswordError()
        }
        return password
      },
      remove: {
        try keychain.remove(key)
      }
    )
  }()
}
