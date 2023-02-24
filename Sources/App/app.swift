import Foundation

import Fingerprint

@main
public struct app {
    public static func main() async {
        do {
            let fingerprintService: IFingerprintService = try FingerprintService(withAPIKey: "12345678")
            // let restAPIService: RestAPIService = try RestAPIService(withAPIKey: "12345678")
            // let token: TRestAPIToken = try await restAPIService.getToken()
            let token: Token = try await fingerprintService.getToken()
            print("restapi gettoken", token)
        // } catch RestAPIServiceErrors.URLError {
        //    print("url error")
        } catch {
            print("generic error \(error)")
        }
    }
}
