import XXClient

extension Message {
  static func stub(_ stubId: Int) -> Message {
    .init(
      messageType: stubId,
      id: "id-\(stubId)".data(using: .utf8)!,
      payload: "payload-\(stubId)".data(using: .utf8)!,
      sender: "sender-\(stubId)".data(using: .utf8)!,
      recipientId: "recipientId-\(stubId)".data(using: .utf8)!,
      ephemeralId: stubId,
      timestamp: stubId,
      encrypted: stubId % 2 == 0,
      roundId: stubId,
      roundURL: "roundURL-\(stubId)"
    )
  }
}
