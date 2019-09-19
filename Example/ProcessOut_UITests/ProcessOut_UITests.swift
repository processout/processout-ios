//
//  ProcessOutUITests.swift
//  ProcessOut_Tests
//
//  Created by Jeremy Lejoux on 09/09/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import Pods_ProcessOut_Example_ProcessOut_UITests
import ProcessOut
import Alamofire

class ProcessOutUITests: XCTestCase {

    var projectId = "test-proj_gAO1Uu0ysZJvDuUpOGPkUBeE3pGalk3x"
    var projectKey = "key_sandbox_mah31RDFqcDxmaS7MvhDbJfDJvjtsFTB"
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        ProcessOut.Setup(projectId: projectId)
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func createInvoice(invoice: Invoice, completion: @escaping (String?, Error?) -> Void) {
        if let body = try? JSONEncoder().encode(invoice), let authorizationHeader = Request.authorizationHeader(user: projectId, password: projectKey) {
            do {
                let json = try JSONSerialization.jsonObject(with: body, options: []) as! [String : Any]
                var headers: HTTPHeaders = [:]
                
                headers[authorizationHeader.key] = authorizationHeader.value
                Alamofire.request("https://api.processout.com/invoices", method: .post, parameters: json, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: {(response) -> Void in
                    switch response.result {
                    case .success(let data):
                        guard let j = data as? [String: AnyObject] else {
                            completion(nil, ProcessOutException.InternalError)
                            return
                        }
                        if let inv = j["invoice"] as? [String: AnyObject], let id = inv["id"] as? String {
                            completion(id, nil)
                        } else {
                            completion(nil, ProcessOutException.InternalError)
                        }
                    default:
                        completion(nil, ProcessOutException.InternalError)
                    }
                })
            } catch {
                completion(nil, error)
            }
        }
    }
    
    func testInvoiceCreation() {
        
        let expectation = XCTestExpectation(description: "Invoice creation")
        let inv = Invoice(name: "test", amount: "12.01", currency: "EUR")
        createInvoice(invoice: inv, completion: {(invoiceId, error) in
            XCTAssertNotNil(invoiceId)
            XCTAssertNil(error)
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testPayment() {
        let expectation = XCTestExpectation(description: "Make card payment")
        let view = ViewController()
        
        let inv = Invoice(name: "test", amount: "12.01", currency: "EUR")
        createInvoice(invoice: inv, completion: {(invoiceId, error) in
            XCTAssertNotNil(invoiceId)
            
            let card = ProcessOut.Card(cardNumber: "424242424242", expMonth: 11, expYear: 20, cvc: "123", name: "test card")
            ProcessOut.Tokenize(card: card, metadata: [:], completion: {(token, error) in
                XCTAssertNotNil(token)
                
                ProcessOut.makeCardPayment(invoiceId: invoiceId!, token: token!, handler: ProcessOut.createThreeDSTestHandler(viewController: view, completion: {(token, error) in
                    XCTAssertNil(error)
                    expectation.fulfill()
                }), with: view)
            })
        })
        
        wait(for: [expectation], timeout: 10.0)
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
