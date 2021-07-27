//
//  ViewController.swift
//  ProcessOut
//
//  Created by Jeremy Lejoux on 01/15/2018.
//  Copyright (c) 2018 Jeremy Lejoux. All rights reserved.
//

import UIKit
import ProcessOut
import PassKit
import WebKit
import Alamofire

class ViewController: UIViewController, PKPaymentAuthorizationViewControllerDelegate {
    
    // These are tests credentials from a tests project on ProcessOut production env
    var projectId = "test-proj_gAO1Uu0ysZJvDuUpOGPkUBeE3pGalk3x"
    var projectKey = "key_sandbox_mah31RDFqcDxmaS7MvhDbJfDJvjtsFTB"
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusBar: UIView!
    @IBOutlet weak var testNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        statusBar.backgroundColor = UIColor.orange
        
        // Retrieve the current test name if tests are running
        guard let testName = UserDefaults.standard.string(forKey: "testName") else {
            return
        }
        
        self.testNameLabel.text = "Testing: " + testName
    }

    // Pay button clicked
    @IBAction func clicked(_ sender: Any) {
        statusLabel.text = "Requesting payment..."
        statusBar.backgroundColor = UIColor.orange
    
        self.startPayment()
    }
    
    /*
        Some UI helpers
    */
    func setPaymentAsFailed() {
        self.statusBar.backgroundColor = UIColor.red
        self.statusLabel.text = "PAYMENT FAILED"
    }
    
    func setPaymentAsSuccess() {
        self.statusBar.backgroundColor = UIColor.green
        self.statusLabel.text = "Payment successful"
    }
    
    /*
        Payment functions
    */
    func startPayment() {
        guard let cardNumber = UserDefaults.standard.string(forKey: "card") else {
            self.setPaymentAsFailed()
            return
        }
        
        let contact = ProcessOut.Contact(address1: "1 great street", address2: nil, city: "City", state: "State", zip: "10000", countryCode: "US")
        let card = ProcessOut.Card(cardNumber: cardNumber, expMonth: 10, expYear: 24, cvc: "737", name: "Mr", contact: contact)
        // Create invoice
        let inv = Invoice(name: "test 3DS", amount: "12.01", currency: "EUR")
        createInvoice(invoice: inv, completion: {(invoiceId, error) in
            guard error == nil else {
                self.setPaymentAsFailed()
                return
            }
            
            ProcessOut.Tokenize(card: card, metadata: [:], completion: {(token, error) -> Void in
                guard error == nil else {
                    self.setPaymentAsFailed()
                    return
                }
                
                ProcessOut.makeCardPayment(invoiceId: invoiceId!, token: token!, handler: ProcessOut.createThreeDSTestHandler(viewController: self, completion: { (invoiceId, error) in
                    // Send the invoice to your backend to complete the charge
                    guard error == nil else {
                        self.setPaymentAsFailed()
                        return
                    }
                    
                    self.setPaymentAsSuccess()
                }), with: self)
            })
        })
    }
    
    func testApplePay() {
        let request = PKPaymentRequest()
        let paymentNetworks:[PKPaymentNetwork] = [.amex,.masterCard,.visa]
        request.merchantIdentifier = "merchant.jeremy-test"
        request.countryCode = "FR"
        request.currencyCode = "EUR"
        request.supportedNetworks = paymentNetworks
        
        
        // This is based on using Stripe
        request.merchantCapabilities = .capability3DS
        
        if #available(iOS 9.0, *) {
            let tshirt = PKPaymentSummaryItem(label: "T-shirt", amount: NSDecimalNumber(decimal:1.00), type: .final)
            request.paymentSummaryItems = [tshirt]
            
            let applePayController = PKPaymentAuthorizationViewController(paymentRequest: request)
            applePayController?.delegate = self
            present(applePayController!, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
        }
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping ((PKPaymentAuthorizationStatus) -> Void)) {
        let contact = ProcessOut.Contact(address1: "1 great street", address2: "Address 2", city: "City", state: "State", zip: "10000", countryCode: "US")
        ProcessOut.Tokenize(payment: payment, metadata: [:], contact: contact, completion: {token, err in
            if token == nil {
                completion(PKPaymentAuthorizationStatus.failure)
            } else {
                completion(PKPaymentAuthorizationStatus.success)
            }
        }
            
        )
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

