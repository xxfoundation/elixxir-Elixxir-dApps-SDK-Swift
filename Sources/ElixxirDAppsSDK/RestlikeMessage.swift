import Foundation

public struct RestlikeMessage: Equatable {
    public init(
        version: Int,
        headers: Data,
        content: Data,
        method: Int,
        uri: String,
        error: String
    ) {
        self.version = version
        self.headers = headers
        self.content = content
        self.method = method
        self.uri = uri
        self.error = error
    }
    
    public var version: Int?
    public var headers: Data?
    public var content: Data?
    public var method: Int?
    public var uri: String?
    public var error: String?
}

extension RestlikeMessage: Codable {
    enum CodingKeys: String, CodingKey {
        case version = "Version"
        case headers = "Headers"
        case content = "Content"
        case method = "Method"
        case uri = "URI"
        case error = "Error"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decodeIfPresent(Int.self, forKey: .version)
        headers = try container.decodeIfPresent(Data.self, forKey: .headers)
        content = try container.decodeIfPresent(Data.self, forKey: .content)
        method = try container.decodeIfPresent(Int.self, forKey: .method)
        uri = try container.decodeIfPresent(String.self, forKey: .uri)
        error = try container.decodeIfPresent(String.self, forKey: .error)
    }
}
