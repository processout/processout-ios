//
//  POCustomerToken.swift
//  ProcessoOut
//
//  Created by Julien.Rodrigues on 02/11/2022.
//

import Foundation

@_spi(PO)
public struct POCustomerToken: Decodable {

    /// String value that uniquely identifies this customer's token.
    public let id: String
}
