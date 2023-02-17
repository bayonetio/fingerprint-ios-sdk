import Foundation
import FoundationNetworking

let liveEnvironment: String = "live"
let stagingEnvironment: String = "staging"

let developmentBaseURL: String = "http://localhost:9000/v3"

/// The service to connect to the Rest API
public class RestAPIService: IRestAPIService {
    // The user API Key to consume the Rest API service
    private var apiKey: String

    // The Rest API URLs
    let tokenURL: URL

    /// 
    public init(withAPIKey apiKey: String) throws {
        self.apiKey = apiKey

        var baseURL: String = developmentBaseURL
        if let environment: String = ProcessInfo.processInfo.environment["ENVIRONMENT"] {
            switch environment {
                case liveEnvironment:
                    baseURL = "https://staging.bayonet.io/v3"
                case stagingEnvironment:
                    baseURL = "https://bayonet.io/v3"
                default:
                    baseURL = developmentBaseURL
            }
        }

        guard let url: URL = URL(string: "\(baseURL)/token") else {
            throw RestAPIServiceErrors.URLError
        }
        self.tokenURL = url
    }

    /// Fetch a token from the Rest API service
    /// 
    /// - returns: A TRestAPIToken
    public func getToken() async throws -> TRestAPIToken {
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<TRestAPIToken, Error>) in
            let tokenRequest: URLRequest = self.setupRequest(url: self.tokenURL)
            URLSession.shared.dataTask(with: tokenRequest) { (data: Data?, tokenResponse: URLResponse?, error: Error?) in
                if let tokenResponse: HTTPURLResponse = tokenResponse as? HTTPURLResponse {
                    // The token was generated
                    if 200 == tokenResponse.statusCode {
                        if let data: Data = data {
                            let decoder: JSONDecoder = JSONDecoder()
                            do {
                                let response: TRestAPIToken = try decoder.decode(TRestAPIToken.self, from: data)
                                continuation.resume(returning: response)
                            } catch {
                                continuation.resume(throwing: error)
                            }
                        }
                    }
                }
            }.resume()
        }
    }

    /// Prepare a request to use the Rest API service
    /// 
    /// - parameter url: the url
    /// 
    /// - returns: an URLRequest
    private func setupRequest(url: URL) -> URLRequest {
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(self.apiKey)", forHTTPHeaderField: "Authorization")

        return request
    }
}
