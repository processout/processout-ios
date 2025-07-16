//
//  PhoneNumberFieldStyle+Automatic.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 22.05.2025.
//

import SwiftUI

extension POPhoneNumberFieldStyle
    where Self == PODefaultPhoneNumberFieldStyle<POMenuPickerStyle, PODefaultTextFieldStyle> {

    /// The default phone number field style.
    public static var automatic: PODefaultPhoneNumberFieldStyle<POMenuPickerStyle, PODefaultTextFieldStyle> {
        PODefaultPhoneNumberFieldStyle(country: .menu, number: .automatic)
    }
}
