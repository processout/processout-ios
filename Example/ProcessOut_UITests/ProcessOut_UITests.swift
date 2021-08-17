//
//  ProcessOutUITests.swift
//  ProcessOut_Tests
//
//  Created by Jeremy Lejoux on 09/09/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import ProcessOut
import Alamofire

class ProcessOutUITests: XCTestCase {

    // These are tests credentials from a tests project on ProcessOut production env
    var projectId = "test-proj_gAO1Uu0ysZJvDuUpOGPkUBeE3pGalk3x"
    var projectKey = "key_sandbox_mah31RDFqcDxmaS7MvhDbJfDJvjtsFTB"
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        ProcessOut.Setup(projectId: projectId)
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testInvoiceCreation() {
        XCUIApplication().launch()
        
        let expectation = XCTestExpectation(description: "Invoice creation")
        let inv = Invoice(name: "test", amount: "12.01", currency: "EUR")
        createInvoice(invoice: inv, completion: {(invoiceId, error) in
            XCTAssertNotNil(invoiceId)
            XCTAssertNil(error)
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testAuthorisation() {
        XCUIApplication().launch()
        
        let expectation = XCTestExpectation(description: "Invoice authorization")
        let inv = Invoice(name: "test", amount: "12.01", currency: "EUR")
        let card = ProcessOut.Card(cardNumber: "424242424242", expMonth: 11, expYear: 24, cvc: "123", name: "test card")
        let handler = ProcessOut.createThreeDSTestHandler(viewController: UIViewController(), completion: { (invoiceId, error) in
            if invoiceId != nil {
                expectation.fulfill()
            } else {
                // An error occurred
                print(error)
            }
        })
        ProcessOut.Tokenize(card: card, metadata: [:], completion: {(token, error) in
            XCTAssertNotNil(token)
            
            self.createInvoice(invoice: inv, completion: {(invoiceId, error) in
                XCTAssertNotNil(invoiceId)
                
                ProcessOut.makeCardPayment(invoiceId: invoiceId!, token: token!, handler: handler, with: UIViewController())
            })
        })
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testIncrementalAuthorization() {
        XCUIApplication().launch()
        
        let expectation = XCTestExpectation(description: "Incremental invoice authorization")
        let inv = Invoice(name: "test", amount: "12.01", currency: "EUR")
        let card = ProcessOut.Card(cardNumber: "424242424242", expMonth: 11, expYear: 24, cvc: "123", name: "test card")
        let incrementAuthorizationAmountHandler = ProcessOut.createThreeDSTestHandler(viewController: UIViewController(), completion: { (invoiceId, error) in
            if invoiceId != nil {
                expectation.fulfill()
            } else {
                // An error occurred
                print(error)
            }
        })
        let makeCardPaymentHandler = ProcessOut.createThreeDSTestHandler(viewController: UIViewController(), completion: { (invoiceId, error) in
            if invoiceId != nil {
                ProcessOut.incrementAuthorizationAmount(invoiceId: invoiceId!, amount: 5, handler: incrementAuthorizationAmountHandler)
            }
        })
        ProcessOut.Tokenize(card: card, metadata: [:], completion: {(token, error) in
            XCTAssertNotNil(token)
            
            self.createInvoice(invoice: inv, completion: {(invoiceId, error) in
                XCTAssertNotNil(invoiceId)
                
                ProcessOut.makeCardPayment(invoiceId: invoiceId!, token: token!, incremental: true, handler: makeCardPaymentHandler, with: UIViewController())
            })
        })
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testTokenize() {
        XCUIApplication().launch()
        
        // Create an expectation for a background download task.
        let expectation = XCTestExpectation(description: "Tokenize a card")
        
        let card = ProcessOut.Card(cardNumber: "424242424242", expMonth: 11, expYear: 24, cvc: "123", name: "test card")
        ProcessOut.Tokenize(card: card, metadata: [:], completion: {(token, error) in
            XCTAssertNotNil(token)
            expectation.fulfill()
        })
        
        // Wait until the expectation is fulfilled, with a timeout of 10 seconds.
        wait(for: [expectation], timeout: 10.0)
        // This is an example of a functional test case.
    }
    
    func testApmListing() {
        XCUIApplication().launch()
        
        let expectation = XCTestExpectation(description: "List available APM")
        
        ProcessOut.fetchGatewayConfigurations(filter: .AlternativePaymentMethods) { (gateways, error) in
            XCTAssertNotNil(gateways)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // Test that a successful response is returned from the gateway configurations endpoint when pagination is requested
    func testGatewayConfigurationListingWithPagination() {
        XCUIApplication().launch()
        
        let expectation = XCTestExpectation(description: "Fetch gateway configurations with pagination options")
        
        ProcessOut.fetchGatewayConfigurations(filter: .All, paginationOptions: ProcessOut.PaginationOptions(StartAfter: "1234", Limit: 20, Order: "asc")) { (gateways, error) in
            XCTAssertNotNil(gateways)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // Test 3DS2 web payment
    func test3DS2WebPayment() {
        let app = XCUIApplication()
        app.launchArguments = ["-card", "4000000000003246", "-testName", "3DS2 web success"]
        app.launch()
        
        app.buttons["pay"].tap()
        
        sleep(4)
        app.staticTexts["SUCCESSFUL"].tap()
        sleep(3)
        
        XCTAssertEqual(app.staticTexts["statusLabel"].label, "Payment successful" )
    }
    
    // Test 3DS2 web failed payment
    func test3DS2WebFailedPayment() {
        let app = XCUIApplication()
        app.launchArguments = ["-card", "4000000000003246", "-testName", "3DS2 web failed"]
        app.launch()
        
        app.buttons["pay"].tap()
        
        sleep(4)
        app.staticTexts["FAILURE"].tap()
        sleep(3)
        
        XCTAssertEqual(app.staticTexts["statusLabel"].label, "PAYMENT FAILED" )
    }
    
    // Test 3DS2 mobile payment
    func test3DS2NativePayment() {
        let app = XCUIApplication()
        app.launchArguments = ["-card", "4000000000003253", "-testName", "3DS2 native success"]
        app.launch()
        
        app.buttons["pay"].tap()
        
        sleep(4)
        app.buttons["Accept"].tap()
        sleep(3)
        
        XCTAssertEqual(app.staticTexts["statusLabel"].label, "Payment successful" )
    }
    
    // Test 3DS2 refused challenge mobile payment
    func test3DS2FailedPayment() {
        let app = XCUIApplication()
        app.launchArguments = ["-card", "4000000000003253", "-testName", "3DS2 native failed"]
        app.launch()
        
        app.buttons["pay"].tap()
        
        sleep(4)
        app.buttons["Reject"].tap()
        sleep(3)
        
        XCTAssertEqual(app.staticTexts["statusLabel"].label, "PAYMENT FAILED" )
    }
    
    // Test normal failed payment
    func testFailedPayment() {
        let app = XCUIApplication()
        app.launchArguments = ["-card", "4000000000000002", "-testName", "Normal payment failed"]
        app.launch()
        
        app.buttons["pay"].tap()
        
        sleep(3)
        
        XCTAssertEqual(app.staticTexts["statusLabel"].label, "PAYMENT FAILED" )
    }
    
    // Test normal payment
    func testNormalPayment() {
        let app = XCUIApplication()
        app.launchArguments = ["-card", "4977830000000001", "-testName", "Normal payment success"]
        app.launch()
        
        app.buttons["pay"].tap()
        
        sleep(3)
        
        XCTAssertEqual(app.staticTexts["statusLabel"].label, "Payment successful" )
    }
    
    // HELPERS functions
    func createInvoice(invoice: Invoice, completion: @escaping (String?, Error?) -> Void) {
        guard let body = try? JSONEncoder().encode(invoice), let authorizationHeader = Request.authorizationHeader(user: projectId, password: projectKey) else {
            completion(nil, ProcessOutException.InternalError)
            return
        }
        
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
                    
                    guard let inv = j["invoice"] as? [String: AnyObject], let id = inv["id"] as? String else {
                        completion(nil, ProcessOutException.InternalError)
                        return
                    }
                    
                    completion(id, nil)
                default:
                    completion(nil, ProcessOutException.InternalError)
                }
            })
        } catch {
            completion(nil, error)
        }
    }
    
    func createCustomer(completion: @escaping (String?, Error?) -> Void) {
        let customerRequest = CustomerRequest(firstName: "test", lastName: "test", currency: "USD")
        guard let body = try? JSONEncoder().encode(customerRequest), let authorizationHeader = Request.authorizationHeader(user: projectId, password: projectKey) else {
            completion(nil, ProcessOutException.InternalError)
            return
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: body, options: []) as! [String: Any]
            var headers: HTTPHeaders = [:]
            headers[authorizationHeader.key] = authorizationHeader.value
            Alamofire.request("https://api.processout.com/customers", method: .post, parameters: json, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
                switch response.result {
                case .success(let data):
                    guard let j = data as? [String: AnyObject] else {
                        completion(nil, ProcessOutException.InternalError)
                        return
                    }
                    guard let cust = j["customer"] as? [String: AnyObject], let id = cust["id"] as? String else {
                        completion(nil, ProcessOutException.InternalError)
                        return
                    }
                    completion(id, nil)
                default:
                    completion(nil, ProcessOutException.InternalError)
                }
            }
        } catch {
            completion(nil, ProcessOutException.InternalError)
        }
    }
    
    func createCustomerToken(customerId: String, cardId: String, completion: @escaping (String?, Error?) -> Void) {
        let tokenRequest = CustomerTokenRequest(source: cardId)
        guard let body = try? JSONEncoder().encode(tokenRequest), let authorizationHeader = Request.authorizationHeader(user: projectId, password: projectKey) else {
            completion(nil, ProcessOutException.InternalError)
            return
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: body, options: []) as! [String: AnyObject]
            var headers: HTTPHeaders = [:]
            headers[authorizationHeader.key] = authorizationHeader.value
            Alamofire.request("https://api.processout.com/customers/" + customerId + "/tokens", method: .post, parameters: json, encoding :JSONEncoding.default, headers: headers).responseJSON {(response) in
                switch response.result {
                case .success(let data):
                    guard let j = data as? [String: AnyObject] else {
                        completion(nil, ProcessOutException.InternalError)
                        return
                    }
                    guard let cust = j["token"] as? [String: AnyObject], let id = cust["id"] as? String else {
                        completion(nil, ProcessOutException.InternalError)
                        return
                    }
                    completion(id, nil)
                default:
                    completion(nil, ProcessOutException.InternalError)
                }
            }
        } catch {
            completion(nil, ProcessOutException.InternalError)
        }
    }
}
