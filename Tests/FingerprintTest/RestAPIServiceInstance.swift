import XCTest
import Swifter

@testable import Fingerprint

final class RestAPIServiceInstanceTests: XCTestCase {
    let mockServer = HttpServer()

    override func setUp() {
        super.setUp()

        mockServer["/v3/token"] = { request_ in HttpResponse.ok(.json("{\"bayonet_id\":\"probando\"}")) }
    }

    override func tearDown() {
        super.tearDown()
    }

    func testInstanceService() {
        XCTAssertThrowsError(try RestAPIService(withAPIKey: "")) { error in
            XCTAssertEqual(error as! RestAPIServiceErrors, RestAPIServiceErrors.InitError(message: "The API key cannot be empty"))
        }
    }
}
