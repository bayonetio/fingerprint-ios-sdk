public struct Token {
    let bayonetID: String
    let environment: String?
}

public protocol IFingerprintService {
    func getToken() async throws -> Token
    // func refrestToken(tokenID: String) async throws -> Bool
}
