import Foundation
import FoundationNetworking

public enum Errors: Error {
    case GeneralError
}

/// The fingerprint service to generate device's fingerprint
public class FingerprintService: IFingerprintService {
    private var restAPIService: IRestAPIService

    public init(withAPIKey apiKey: String) throws {
        do {
            let restAPIService: IRestAPIService = try RestAPIService(withAPIKey: apiKey)

            self.restAPIService = restAPIService
        } catch {
            throw error
        }
    }

    public func getToken() async throws -> Token {
        let restAPIToken: TRestAPIToken = try await self.restAPIService.getToken()

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Token, Error>) in
            let token: Token = Token(
                bayonetID: restAPIToken.bayonetID, 
                environment: restAPIToken.environment
            )

            continuation.resume(returning: token)
        }
    }
}
