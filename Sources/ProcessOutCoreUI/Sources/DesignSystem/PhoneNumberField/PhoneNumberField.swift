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

    public init(phoneNumber: Binding<POPhoneNumber>, countryPrompt: () -> some View, numberPrompt: String) {
        self._phoneNumber = phoneNumber
        self.countryPrompt = AnyView(countryPrompt())
        self.numberPrompt = numberPrompt
    }

    // MARK: - View

    public var body: some View {
        let configuration = POPhoneNumberFieldStyleConfiguration {
            POPicker(selection: $phoneNumber.territory) {
                ForEach(availableTerritories ?? []) { territory in
                    Text("\(territory.displayName) (+\(territory.code))")
                        .id(territory)
                }
            } prompt: {
                countryPrompt
            } currentValueLabel: {
                if let territory = phoneNumber.territory {
                    Text("+\(territory.code)")
                }
            }
        } number: {
            POTextField(text: $phoneNumber.number, formatter: formatter, prompt: numberPrompt)
        }
        AnyView(erasing: style.makeBody(configuration: configuration))
            .onTextFieldEditingWillChange { newValue in
                attemptToUpdatePhoneNumberTerritory(newValue: newValue)
            }
    }

    // MARK: - Private Properties

    private let countryPrompt: AnyView, numberPrompt: String

    private var formatter: POPhoneNumberFormatter {
        let formatter = POPhoneNumberFormatter()
        formatter.originAssumption = nil
        formatter.preferInternationalFormat = false
        formatter.defaultRegion = phoneNumber.territory?.id
        return formatter
    }

    @Binding
    private var phoneNumber: POPhoneNumber

    @Environment(\.phoneNumberFieldTerritories)
    private var availableTerritories

    @Environment(\.phoneNumberFieldStyle)
    private var style

    // MARK: - Private Methods

    private func attemptToUpdatePhoneNumberTerritory(newValue: String) {
        let parser = POPhoneNumberParser()
        guard let phoneNumber = parser.parse(number: newValue) else {
            return
        }
        let newTerritory = availableTerritories?.first { $0.code == phoneNumber.countryCode }
        self.phoneNumber.territory = newTerritory
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var number = POPhoneNumber(territory: nil, number: "")
    POPhoneNumberField(
        phoneNumber: $number,
        countryPrompt: {
            Text("Country")
        },
        numberPrompt: "Phone Number"
    )
    .phoneNumberFieldTerritories([
        POPhoneNumber.Territory(id: "UA", displayName: "Ukraine", code: "380"),
        POPhoneNumber.Territory(id: "PL", displayName: "Poland", code: "48"),
        POPhoneNumber.Territory(id: "CA", displayName: "Canada", code: "1"),
        POPhoneNumber.Territory(id: "US", displayName: "United States", code: "1")
    ])
    .padding()
}
