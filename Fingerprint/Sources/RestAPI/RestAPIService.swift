import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

let liveEnvironment: String = "live"
let stagingEnvironment: String = "staging"
let testEnvironment: String = "test"

let developmentBaseURL: String = "http://localhost:9000/v3"

/// The service to connect to the Rest API
public class RestAPIService: RestAPIServiceProtocol {
    // The user API Key to consume the Rest API service
    private var apiKey: String

    private let baseURL: String

    /// 
    public init(withAPIKey apiKey: String) throws {
        if apiKey.count < 1 {
            throw RestAPIServiceErrors.InitError(message: "The API key cannot be empty")
        }

        self.apiKey = apiKey

        /// TODO: Refactor the base url by environment
        var baseURL: String = developmentBaseURL
        if let environment: String = ProcessInfo.processInfo.environment["ENVIRONMENT"] {
            switch environment {
                case liveEnvironment:
                    baseURL = "https://live.bayonet.io/v3"
                case stagingEnvironment:
                    baseURL = "https://staging.bayonet.io/v3"
                case testEnvironment:
                    baseURL = "http://localhost:8080/v3"
                default:
                    baseURL = developmentBaseURL
            }
        }

        guard let _: URL = URL(string: "\(baseURL)") else {
            throw RestAPIServiceErrors.URLError(message: "base")
        }
        self.baseURL = baseURL
    }

    /// Fetch a token from the Rest API service
    /// 
    /// - returns: A TRestAPIToken
    public func getToken() async throws -> TRestAPIToken {
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<TRestAPIToken, Error>) in
            // Prepare the url for token generator
            guard let tokenURL: URL = URL(string: "\(baseURL)/token") else {
                continuation.resume(throwing: RestAPIServiceErrors.URLError(message: "Invalid token url"))
                return
            }

            let tokenRequest: URLRequest = self.setupRequest(url: tokenURL)
            let task: URLSessionDataTask = URLSession.shared.dataTask(with: tokenRequest) { (data: Data?, tokenResponse: URLResponse?, error: Error?) in
                var currentError: Error? = nil
                var restAPIToken: TRestAPIToken? = nil
                if let tokenResponse: HTTPURLResponse = tokenResponse as? HTTPURLResponse {
                    switch tokenResponse.statusCode {
                        case 401:
                            currentError = RestAPIServiceErrors.UnauthorizedError
                        case 400...499:
                            currentError = RestAPIServiceErrors.RequestError
                        case 500...599:
                            currentError = RestAPIServiceErrors.ServerError
                        case 200:
                            if let data: Data = data {
                                let decoder: JSONDecoder = JSONDecoder()
                                do {
                                    restAPIToken = try decoder.decode(TRestAPIToken.self, from: data)
                                } catch {
                                    currentError = RestAPIServiceErrors.TransformBodyResponseError(message: error.localizedDescription)
                                }
                            } else {
                                currentError = RestAPIServiceErrors.ResponseBodyIsEmptyError
                            }
                        default:
                            currentError = RestAPIServiceErrors.UnknwonError
                    }
                }

                if let restAPIToken: TRestAPIToken = restAPIToken {
                    continuation.resume(returning: restAPIToken)
                } else if let currentError: Error = currentError {
                    continuation.resume(throwing: currentError)
                } else {
                    continuation.resume(throwing: RestAPIServiceErrors.UnknwonError)
                }
            }
            task.resume()
        }
    }

    public func refresh(token: Token) async throws -> Bool {
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Bool, Error>) in
            // Prepare the url to refresh
            guard let refreshTokenURL: URL = URL(string: "\(self.baseURL)/refresh/\(token.bayonetID)") else {
                continuation.resume(throwing: RestAPIServiceErrors.URLError(message: "Invalid refresh url"))
                return
            }
            let tokenRequest: URLRequest = self.setupRequest(url: refreshTokenURL, method: "POST")

            let task: URLSessionDataTask = URLSession.shared.dataTask(with: tokenRequest) { (data: Data?, tokenResponse: URLResponse?, error: Error?) in
                var currentError: Error? = nil
                if let tokenResponse: HTTPURLResponse = tokenResponse as? HTTPURLResponse {
                    switch tokenResponse.statusCode {
                        case 401:
                            currentError = RestAPIServiceErrors.UnauthorizedError
                            break
                        case 400...499:
                            currentError = RestAPIServiceErrors.RequestError
                            break
                        case 500...599:
                            currentError = RestAPIServiceErrors.ServerError
                            break
                        case 200:
                            break
                        default:
                            currentError = RestAPIServiceErrors.UnknwonError
                    }
                }

                if let err: Error = currentError {
                    continuation.resume(throwing: err)
                } else {
                    continuation.resume(returning: true)
                }
            }
            task.resume()
        }
    }

    /// Prepare a request to use the Rest API service
    /// 
    /// - parameter url: the url
    /// 
    /// - returns: an URLRequest
    private func setupRequest(url: URL, method: String = "GET") -> URLRequest {
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("Bearer \(self.apiKey)", forHTTPHeaderField: "Authorization")

        return request
    }
}
