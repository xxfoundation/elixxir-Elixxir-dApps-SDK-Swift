import Foundation

func secureRandomData(count: Int) -> Data {
  var bytes = [Int8](repeating: 0, count: count)
  let status = SecRandomCopyBytes(kSecRandomDefault, count, &bytes)
  assert(status == errSecSuccess)
  return Data(bytes: bytes, count: count)
}

extension Data {
  func jsonEncodedBase64() -> String {
    let encoder = JSONEncoder()
    encoder.dataEncodingStrategy = .base64
    let data = try! encoder.encode(self)
    return String(data: data, encoding: .utf8)!
  }
}
