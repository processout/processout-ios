import UIKit
import XCTest
import ProcessOut

class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        ProcessOut.Setup(projectId: "test-proj_gAO1Uu0ysZJvDuUpOGPkUBeE3pGalk3x")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTokenize() {
        // Create an expectation for a background download task.
        let expectation = XCTestExpectation(description: "Tokenize a card")
        
        let card = ProcessOut.Card(cardNumber: "424242424242", expMonth: 11, expYear: 20, cvc: "123", name: "test card")
        ProcessOut.Tokenize(card: card, metadata: [:], completion: {(token, error) in
            XCTAssertNotNil(token)
            expectation.fulfill()
        })
        
        // Wait until the expectation is fulfilled, with a timeout of 10 seconds.
        wait(for: [expectation], timeout: 10.0)
        // This is an example of a functional test case.
    }
    
    func testApmListing() {
        let expectation = XCTestExpectation(description: "List available APM")
        
        ProcessOut.listAlternativeMethods(completion: {(gateways, error) in
            
            XCTAssertNotNil(gateways)
            
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 10.0)
    }
}
