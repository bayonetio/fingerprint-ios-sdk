import Foundation

public struct Token {
    public let bayonetID: String
    public let environment: String?
}

@available(macOS 10.15.0, *)
public protocol FingerprintServiceProtocol {
    func getToken() async throws -> Token
    // func refrestToken(tokenID: String) async throws -> Bool
}
