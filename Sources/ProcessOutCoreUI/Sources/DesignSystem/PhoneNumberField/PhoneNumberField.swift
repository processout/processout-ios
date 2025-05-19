//
//  PhoneNumberField.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.05.2025.
//

import SwiftUI
@_spi(PO) import ProcessOut

@_spi(PO)
@available(iOS 14.0, *)
public struct POPhoneNumberField: View {

    public init(phoneNumber: Binding<POPhoneNumber>) {
        self._phoneNumber = phoneNumber
    }

    // MARK: - View

    public var body: some View {
        HStack(spacing: POSpacing.extraSmall) {
            POPicker(selection: $phoneNumber.territory) {
                ForEach(phoneNumber.territories) { territory in
                    Button { } label: {
                        Text(territory.displayName)
                        Text("+\(territory.code)")
                    }
                    .id(territory)
                }
            } prompt: {
                Text("Country")
            } currentValueLabel: {
                if let territory = phoneNumber.territory {
                    Text("+\(territory.code)")
                }
            }
            .pickerStyle(POMenuPickerStyle.menu)
            .controlWidth(.regular)
            POTextField(text: $phoneNumber.number, formatter: formatter, prompt: "Number")
        }
    }

    // MARK: - Private Properties

    private var formatter: POPhoneNumberFormatter {
        let formatter = POPhoneNumberFormatter()
        formatter.originAssumption = .national
        formatter.preferInternationalFormat = false
        formatter.defaultRegion = phoneNumber.territory?.id
        return formatter
    }

    @Binding
    private var phoneNumber: POPhoneNumber

    // MARK: - Private Methods
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var number = POPhoneNumber(territory: nil, number: "")
    POPhoneNumberField(phoneNumber: $number)
        .padding()
}
