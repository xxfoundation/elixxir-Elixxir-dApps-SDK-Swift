import XXClient

extension Array where Element == AuthCallbacks.Callback {
  static let stubs: [AuthCallbacks.Callback] = [
    .confirm(
      contact: .unimplemented("contact-1".data(using: .utf8)!),
      receptionId: "reception-id-1".data(using: .utf8)!,
      ephemeralId: 1,
      roundId: 1
    ),
    .request(
      contact: .unimplemented("contact-2".data(using: .utf8)!),
      receptionId: "reception-id-2".data(using: .utf8)!,
      ephemeralId: 2,
      roundId: 2
    ),
    .reset(
      contact: .unimplemented("contact-3".data(using: .utf8)!),
      receptionId: "reception-id-3".data(using: .utf8)!,
      ephemeralId: 3,
      roundId: 3
    ),
  ]
}
