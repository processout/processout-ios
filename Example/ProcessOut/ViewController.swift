//
//  ViewController.swift
//  ProcessOut
//
//  Created by Jeremy Lejoux on 01/15/2018.
//  Copyright (c) 2018 Jeremy Lejoux. All rights reserved.
//

import UIKit
import ProcessOut

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func clicked(_ sender: Any) {
        let card = ProcessOut.Card(cardNumber: "4242424242424242", expMonth: 11, expYear: 19, cvc: nil, name: "Jeremy Lejoux")
        
    
        ProcessOut.Tokenize(card: card, metadata: [:], completion: {(token, error) -> Void in
            if error != nil {
                switch error! {
                case .BadRequest(let message):
                    // developers, message can help you
                    print(message)
                case .InternalError:
                    print("An internal error occured")
                case .MissingProjectId:
                    print("Check your app delegate file")
                case .NetworkError:
                    print("Request could not go through")
                }
            } else {
                // send token to your backend to charge the customer
                print(token!)
            }
        })
        
        ProcessOut.UpdateCvc(cardId: "a_card_token", newCvc: "123", completion: { (error) in
            if error != nil {
                // an error occured
                print(error!)
            } else {
                // card CVC updated
            }
        })
    }
}

