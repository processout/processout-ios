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

class ViewController: UIViewController, PKPaymentAuthorizationViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func clicked(_ sender: Any) {
        // either test applepaye tokenization or card
        let contact = ProcessOut.Contact(address1: "1 great street", address2: nil, city: "City", state: "State", zip: "10000", countryCode: "US")
        let card = ProcessOut.Card(cardNumber: "4000000000003246", expMonth: 10, expYear: 20, cvc: "737", name: "Jeremy Lejoux", contact: contact)
        ProcessOut.Tokenize(card: card, metadata: [:], completion: {(token, error) -> Void in
            if error != nil {
                switch error! {
                case .BadRequest(let message, let code):
                    // developers, message can help you
                    print(message, code)
                    
                case .MissingProjectId:
                    print("Check your app delegate file")
                case .InternalError:
                    print("An internal error occured")
                case .NetworkError:
                    print("Request could not go through")
                case .GenericError(let error):
                    print(error)
                }
            } else {
                // Use the card token to initiate an authorization/charge
                if token != nil {
                    //Initiate a card payment from an invoice generated on your backend
                    ProcessOut.makeCardPayment(invoiceId: "invoice-id", token: token!, handler: ProcessOut.createThreeDSTestHandler(viewController: self, completion: { (invoiceId, error) in
                        // Send the invoice to your backend to complete the charge
                        print(invoiceId)
                        print(error)
                    }), with: self)
                }
            }
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
}

