import Foundation

public struct Token: Codable {
    public let bayonetID: String
    public let environment: String?
}

@available(iOS 15.0, *)
public protocol FingerprintServiceProtocol {
    func analyze() async throws -> Token
}
