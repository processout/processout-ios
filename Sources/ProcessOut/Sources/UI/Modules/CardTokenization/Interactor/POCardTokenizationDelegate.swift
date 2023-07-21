//
//  POCardTokenizationDelegate.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 18.07.2023.
//

import Foundation

public protocol POCardTokenizationDelegate: AnyObject {

    /// maybe use completion to allow merchant to create token dynamically
    func assignCustomerTokenRequest(for source: String) -> POAssignCustomerTokenRequest?

    /// 
    func invoiceAuthorizationRequest(for source: String) -> POInvoiceAuthorizationRequest?
}
