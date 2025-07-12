//
//  PhoneNumberField.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.05.2025.
//

import SwiftUI
@_spi(PO) import ProcessOut

@available(iOS 14.0, *)
@_spi(PO)
public struct POPhoneNumberField: View {

    public init(phoneNumber: Binding<POPhoneNumber>, countryPrompt: () -> some View, numberPrompt: String) {
        self._phoneNumber = phoneNumber
        self.countryPrompt = AnyView(countryPrompt())
        self.numberPrompt = numberPrompt
    }

    // MARK: - View

    public var body: some View {
        let configuration = POPhoneNumberFieldStyleConfiguration {
            POPicker(selection: $phoneNumber.territoryId) {
                ForEach(availableTerritories ?? []) { territory in
                    Text("\(territory.displayName) (\(territory.code))")
                }
            } prompt: {
                countryPrompt
            } currentValueLabel: {
                // todo(andrii-vysotskyi): confirm whether performance impact is negligible
                if let territory = availableTerritories?.first(where: { $0.id == phoneNumber.territoryId }) {
                    Text(territory.code)
                }
            }
        } number: {
            POTextField(text: $phoneNumber.number, formatter: formatter, prompt: numberPrompt)
                .poKeyboardType(.numberPad)
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
        formatter.defaultRegion = phoneNumber.territoryId
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
        self.phoneNumber.territoryId = newTerritory?.id
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var number = POPhoneNumber(territoryId: nil, number: "")
    POPhoneNumberField(
        phoneNumber: $number,
        countryPrompt: {
            Text("Country")
        },
        numberPrompt: "Phone Number"
    )
    .phoneNumberFieldTerritories([
        POPhoneNumber.Territory(id: "UA", displayName: "Ukraine", code: "+380"),
        POPhoneNumber.Territory(id: "PL", displayName: "Poland", code: "+48"),
        POPhoneNumber.Territory(id: "CA", displayName: "Canada", code: "+1"),
        POPhoneNumber.Territory(id: "US", displayName: "United States", code: "+1")
    ])
    .padding()
}
