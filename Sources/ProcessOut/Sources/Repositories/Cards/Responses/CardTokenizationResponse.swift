//
//  CardTokenizationResponse.swift
//  ProcessOut
//
//  Created by Julien.Rodrigues on 20/10/2022.
//

import Foundation

struct CardTokenizationResponse: Decodable, Sendable {
    let card: POCard
}
