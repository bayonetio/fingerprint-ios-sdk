import Foundation

public struct Token: Codable {
    public let bayonetID: String
    public let environment: String?
}

@available(macOS 10.15.0, *)
public protocol FingerprintServiceProtocol {
    func analize() async throws -> Token
}
