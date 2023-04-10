//
//  ConfigurationMapper.swift
//  ProcessOutCheckout
//
//  Created by Andrii Vysotskyi on 27.03.2023.
//

import ProcessOut
import Checkout3DS

protocol ConfigurationMapper {

    /// Converts given processout configuration to Checkout config parameters.
    func convert(configuration: PO3DS2Configuration) -> ThreeDS2ServiceConfiguration.ConfigParameters
}
