import XCTest
import WPKit

class WPKitTests: XCTestCase {
    
    var server: URL? = nil
    let api = WPPublicAPI()
    
    override func setUpWithError() throws {
        let options = importOptions()
        server = URL(string: options["host"] ?? "")
        if server == nil { XCTFail("URL supplied in import options is invalid!") }
    }
    
    func testFetchingPosts() throws {
        XCTAssertNoThrow(try {
            let posts = try api.fetchPosts()
            XCTAssertNotEqual(posts.count, 0)
        }())
    }
    
    func testFetchingPostsWithCompletionHandler() throws {
        let semaphore = DispatchSemaphore(value: 0)
        let _ = api.fetchPosts() { posts, error in
            XCTAssertNil(error)
            XCTAssertNotEqual((posts ?? []).count, 0)
            semaphore.signal()
        }
        semaphore.wait()
    }
}
