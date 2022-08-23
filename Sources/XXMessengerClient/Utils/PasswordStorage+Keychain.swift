import KeychainAccess
import XXClient

extension PasswordStorage {
  public static let keychain: PasswordStorage = {
    let keychain = KeychainAccess.Keychain(
      service: "xx.network.client.messenger"
    )
    return PasswordStorage(
      save: { password in
        keychain[data: "password"] = password
      },
      load: {
        guard let password = keychain[data: "password"] else {
          throw MissingPasswordError()
        }
        return password
      }
    )
  }()
}
