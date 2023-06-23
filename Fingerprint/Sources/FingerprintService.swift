import Foundation

import FingerprintPro

// BAYONET_TOKEN is a key to store the token in the device storage
private let BAYONET_TOKEN: String = "BayonetToken"

public struct FingerprintService: FingerprintServiceProtocol {
    private let defaults: UserDefaults = UserDefaults.standard
    private var restAPIService: RestAPIServiceProtocol

    public init(apiKey: String, withBAYONETENVIRONMENT BAYONET_ENVIRONMENT: String = "production") throws {
        let restAPIService = try RestAPIService(withAPIKey: apiKey, BAYONET_ENVIRONMENT)
        self.restAPIService = restAPIService
    }
    
    @available(iOS 15.0, *)
    public func analize() async throws -> Token {
        var token: Token

        if let storedToken: Token = self.getTokenStored() {
            // Refresh a stored device fingerprint
            do {
                let _: Bool = try await self.restAPIService.refresh(token: storedToken)
            } catch {
                print("error on refresh \(error)")
            }
            
            token = storedToken
        } else {
            // Generate a new device fingerprint
            let restAPIToken: TRestAPIToken = try await self.restAPIService.getToken()

            let fingerprintproService = FingerprintProFactory.getInstance(restAPIToken.services.fingerprintjs.apiKey)
            do {
                var metadata = Metadata()
                metadata.setTag(restAPIToken.bayonetID, forKey: "browserToken")
                if let environment: String = restAPIToken.environment {
                    metadata.setTag(environment, forKey: "environment")
                }

                let _ = try await fingerprintproService.getVisitorId(metadata)
            } catch {
                print("error", error as Any)
            }

            // Build the token
            token = Token(
                bayonetID: restAPIToken.bayonetID,
                environment: restAPIToken.environment
            )

            self.storeToken(token: token)
        }

        return token
    }

    private func getTokenStored() -> Token? {
        var token: Token? = nil

        if let tokenStored: Data = defaults.object(forKey: BAYONET_TOKEN) as? Data {
            let jsonDecoder: JSONDecoder = JSONDecoder()
            if let loadedToken: Token = try? jsonDecoder.decode(Token.self, from: tokenStored) {
                token = loadedToken
            }
        }

        return token
    }

    private func storeToken(token: Token) -> Void {
        let jsonEncoder: JSONEncoder = JSONEncoder()
        
        if let tokenEncoded: Data = try? jsonEncoder.encode(token) {
            self.defaults.set(tokenEncoded, forKey: BAYONET_TOKEN)
        }
    }
}
