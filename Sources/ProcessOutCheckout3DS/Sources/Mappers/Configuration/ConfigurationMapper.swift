//
//  ConfigurationMapper.swift
//  ProcessOutCheckout3DS
//
//  Created by Andrii Vysotskyi on 27.03.2023.
//

import ProcessOut
import Checkout3DS

protocol ConfigurationMapper: Sendable {

    /// Converts given ProcessOut configuration to Checkout config parameters.
    func convert(configuration: PO3DS2Configuration) throws -> ThreeDS2ServiceConfiguration.ConfigParameters
}
