import CustomDump
import XCTest
@testable import ElixxirDAppsSDK

final class IdentityTests: XCTestCase {
  func testCoding() throws {
    let userId = secureRandomData(count: 32)
    let rsaPrivateKey = secureRandomData(count: 32)
    let salt = secureRandomData(count: 32)
    let dhKeyPrivate = secureRandomData(count: 32)
    let jsonString = """
    {
      "ID": \(userId.jsonEncodedBase64()),
      "RSAPrivatePem": \(rsaPrivateKey.jsonEncodedBase64()),
      "Salt": \(salt.jsonEncodedBase64()),
      "DHKeyPrivate": \(dhKeyPrivate.jsonEncodedBase64())
    }
    """
    let jsonData = jsonString.data(using: .utf8)!
    let decoder = JSONDecoder()
    decoder.dataDecodingStrategy = .base64
    let identity = try decoder.decode(Identity.self, from: jsonData)

    XCTAssertNoDifference(identity, Identity(
      id: userId,
      rsaPrivatePem: rsaPrivateKey,
      salt: salt,
      dhKeyPrivate: dhKeyPrivate
    ))

    let encoder = JSONEncoder()
    encoder.dataEncodingStrategy = .base64
    let encodedIdentity = try encoder.encode(identity)
    let decodedIdentity = try decoder.decode(Identity.self, from: encodedIdentity)

    XCTAssertNoDifference(decodedIdentity, identity)
  }
}
