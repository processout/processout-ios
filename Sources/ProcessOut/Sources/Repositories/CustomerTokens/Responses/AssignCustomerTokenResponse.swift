//
//  AssignCustomerTokenResponse.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.03.2023.
//

struct AssignCustomerTokenResponse: Decodable, Sendable {

    /// Optional customer action.
    let customerAction: _CustomerAction?

    /// Token information.
    let token: POCustomerToken?
}
