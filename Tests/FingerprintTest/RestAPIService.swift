import XCTest
import Swifter

@testable import Fingerprint

let mockServer: HttpServer = HttpServer()

final class RestAPIServiceTests: XCTestCase {
    // private let mockServer: HttpServer = HttpServer()

    override class func setUp() {
        
                
        mockServer["/v3/token"] = { (rqst: HttpRequest) in
            let authorizationRequestHeader: [String : String] = rqst.headers.filter { $0.key == "authorization" }
            if let authorization: String =  authorizationRequestHeader["authorization"] {
                if authorization.contains("unauthorized") {
                    return .unauthorized
                } else if authorization.contains("movedpermanently") {
                    return .movedPermanently("")
                } else if authorization.contains("badrequest") {
                    return .badRequest(nil)
                } else if authorization.contains("withenvironment") {
                    return .ok(.text("""
                    {"bayonet_id":"generated-token","environment":"sandbox","services":{"fingerprintjs":{"apikey":"fingerprint"}}}
                    """))
                } else if authorization.contains("testapikey") {
                    return .ok(.text("""
                    {"bayonet_id":"generated-token","services":{"fingerprintjs":{"apikey":"fingerprint"}}}
                    """))
                }
            }

            return .internalServerError
        }

        do {
            try mockServer.start()
        } catch {
            print("error on starting the server")
        }
    }

    func testServerError() async throws {
        let service: RestAPIService = try RestAPIService(withAPIKey: "servererror")
        do {
            _ = try await service.getToken()
        } catch {
            XCTAssertNotNil(error)
            XCTAssertEqual(error as! RestAPIServiceErrors, RestAPIServiceErrors.ServerError)
        }
    }

    func testUnauthorizedError() async throws {
        let service: RestAPIService = try RestAPIService(withAPIKey: "unauthorized")
        do {
            _ = try await service.getToken()
        } catch {
            XCTAssertNotNil(error)
            XCTAssertEqual(error as! RestAPIServiceErrors, RestAPIServiceErrors.UnauthorizedError)
        }
    }

    func testBadRequestError() async throws {
        let service: RestAPIService = try RestAPIService(withAPIKey: "badrequest")
        do {
            _ = try await service.getToken()
        } catch {
            XCTAssertNotNil(error)
            XCTAssertEqual(error as! RestAPIServiceErrors, RestAPIServiceErrors.RequestError)
        }
    }

    func testMovedError() async throws {
        let service: RestAPIService = try RestAPIService(withAPIKey: "movedpermanently")
        do {
            _ = try await service.getToken()
        } catch {
            XCTAssertNotNil(error)
            XCTAssertEqual(error as! RestAPIServiceErrors, RestAPIServiceErrors.UnknwonError)
        }
    }

    func testHappyPath() async throws {
        let service: RestAPIService = try RestAPIService(withAPIKey: "testapikey")
        let token: TRestAPIToken = try await service.getToken()
        XCTAssertEqual(token.bayonetID, "generated-token")
        XCTAssertNil(token.environment)
    }

    func testHappyPathWithEnvironment() async throws {
        let service: RestAPIService = try RestAPIService(withAPIKey: "withenvironment")
        let token: TRestAPIToken = try await service.getToken()
        XCTAssertEqual(token.bayonetID, "generated-token")
        XCTAssertNotNil(token.environment)
        XCTAssertEqual(token.environment, "sandbox")
    }
}
