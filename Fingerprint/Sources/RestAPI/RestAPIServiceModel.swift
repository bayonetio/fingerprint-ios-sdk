///
struct TFingerprintJSServiceConfiguration: Codable {
    let apiKey: String

    enum CodingKeys: String, CodingKey {
        case apiKey = "apiKey"
    }
}

///
struct TExternalServicesConfiguration: Codable {
    let fingerprintjs: TFingerprintJSServiceConfiguration

    enum CodingKeys: String, CodingKey {
        case fingerprintjs = "fingerprintjs"
    }
}

public struct TRestAPIToken: Codable {
    let bayonetID: String
    let environment: String?
    let services: TExternalServicesConfiguration

    enum TRestAPIToken: String, CodingKey {
        case bayonetID = "bayonet_id"
        case environment = "environment"
        case services = "services"

        enum ServicesNestedKey: String, CodingKey {
            case fingerprintjs = "fingerprintjs"

            enum FingerprintjsNestedKey: String, CodingKey {
                case apiKey = "apikey"
            }
        }
    }

    public init(from decoder: Decoder) throws {
        // Prepare the container
        let tokenBayonetContainer = try decoder.container(keyedBy: TRestAPIToken.self)

        // Assign the basic values
        bayonetID = try tokenBayonetContainer.decode(String.self, forKey: .bayonetID)
        do {
            environment = try tokenBayonetContainer.decode(String.self, forKey: .environment)
        } catch {
            environment = nil
        }


        // Assign the nested values
        let servicesContainer = try tokenBayonetContainer.nestedContainer(keyedBy: TRestAPIToken.ServicesNestedKey.self, forKey: .services)
        let fingerprintjsContainer = try servicesContainer.nestedContainer(keyedBy: TRestAPIToken.ServicesNestedKey.FingerprintjsNestedKey.self, forKey: .fingerprintjs)
        let fingerprintjsApiKey = try fingerprintjsContainer.decode(String.self, forKey: .apiKey)

        let fingerprintjs = TFingerprintJSServiceConfiguration(
            apiKey: fingerprintjsApiKey
        )
        let externalServicesConfiguration = TExternalServicesConfiguration(
            fingerprintjs: fingerprintjs
        )

        services = externalServicesConfiguration
    }
}

public enum RestAPIServiceErrors: Error, Equatable {
    case InitError(message: String)
    case URLError
    case NetworkError
    case RequestError
    case ServerError
    case TransformBodyResponseError(message: String)
    case ResponseBodyIsEmptyError
    case UnknwonError
    case UnauthorizedError
}

public protocol RestAPIServiceProtocol {
    func getToken() async throws -> TRestAPIToken
}
