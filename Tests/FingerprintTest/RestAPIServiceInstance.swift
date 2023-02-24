import XCTest
import Swifter

@testable import Fingerprint

final class RestAPIServiceInstanceTests: XCTestCase {
    func testInstanceService() {
        XCTAssertThrowsError(try RestAPIService(withAPIKey: "")) { error in
            XCTAssertEqual(error as! RestAPIServiceErrors, RestAPIServiceErrors.InitError(message: "The API key cannot be empty"))
        }
    }
}
