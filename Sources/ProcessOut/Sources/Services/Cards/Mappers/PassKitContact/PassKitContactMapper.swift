//
//  PassKitContactMapper.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 18.12.2023.
//

import PassKit

protocol PassKitContactMapper {

    /// Converts given `PKContact` instance to `POContact`.
    func map(contact: PKContact) -> POContact
}
