//
//  WebAuthenticationRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 31.10.2024.
//

import Foundation

struct WebAuthenticationRequest {

    /// A URL pointing to the authentication webpage.
    let url: URL

    /// Callback.
    let callback: POWebAuthenticationCallback?
}
