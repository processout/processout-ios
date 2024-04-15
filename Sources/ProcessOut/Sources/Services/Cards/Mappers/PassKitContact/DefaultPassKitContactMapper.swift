//
//  DefaultPassKitContactMapper.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 18.12.2023.
//

import PassKit

final class DefaultPassKitContactMapper: PassKitContactMapper {

    init(logger: POLogger) {
        self.logger = logger
    }

    // MARK: - PassKitContactMapper

    func map(contact pkContact: PKContact) -> POContact {
        guard let address = pkContact.postalAddress else {
            return POContact()
        }
        var addressLines = address.street.components(separatedBy: .newlines)
        if addressLines.count > 2 {
            logger.debug("Too many address components: \(addressLines.count)")
            let address2 = addressLines.suffix(1).joined(separator: "\n")
            addressLines.removeLast(addressLines.count - 1)
            addressLines.append(address2)
        }
        let contact = POContact(
            address1: addressLines.first,
            address2: addressLines[safe: 1],
            city: address.city,
            state: address.state,
            zip: address.postalCode,
            countryCode: address.isoCountryCode,
            phone: pkContact.phoneNumber?.stringValue
        )
        return contact
    }

    // MARK: - Private Properties

    private let logger: POLogger
}
