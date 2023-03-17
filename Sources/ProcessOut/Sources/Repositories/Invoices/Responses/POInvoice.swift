//
//  POInvoice.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 24.10.2022.
//

import Foundation

@_spi(PO)
public struct POInvoice: Decodable {

    /// String value that uniquely identifies this invoice.
    public let id: String

    /// Application will be redirected to this URL in case of success. Useful for web based operations. 
    public let returnUrl: URL?
}
