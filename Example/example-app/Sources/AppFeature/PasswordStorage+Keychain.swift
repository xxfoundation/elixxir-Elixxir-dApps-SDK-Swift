import ElixxirDAppsSDK
import KeychainAccess

extension PasswordStorage {
  static let keychain: PasswordStorage = {
    let keychain = KeychainAccess.Keychain(
      service: "xx.network.dApps.ExampleApp"
    )
    return PasswordStorage(
      save: { password in keychain[data: "password"] = password},
      load: { try keychain[data: "password"] ?? { throw MissingPasswordError() }() }
    )
  }()
}
