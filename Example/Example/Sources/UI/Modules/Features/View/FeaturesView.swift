//
//  FeaturesView.swift
//  Example
//
//  Created by Andrii Vysotskyi on 28.10.2022.
//

import SwiftUI
import PassKit
@_spi(PO) import ProcessOutUI

struct FeaturesView: View {

    var body: some View {
        List {
            Section(String(localized: .Features.availableFeatures)) {
                NavigationLink(String(localized: .Features.alternativePayment)) {
                    AlternativePaymentsView()
                }
                NavigationLink(String(localized: .Features.cardPayment)) {
                    CardPaymentView()
                }
                NavigationLink(String(localized: .Features.cardScanner)) {
                    CardScannerView()
                }
                NavigationLink(String(localized: .Features.dynamicCheckout)) {
                    DynamicCheckoutView()
                }
                if isApplePayAvailable {
                    NavigationLink(String(localized: .Features.applePay)) {
                        ApplePayView()
                    }
                }
            }
            Section {
                NavigationLink(String(localized: .Features.applicationConfiguration)) {
                    ConfigurationView()
                }
            }
        }
        .onAppear {
            updateApplePayAvailability()
        }
        .listStyle(.insetGrouped)
        .navigationTitle(String(localized: .Features.title))
    }

    // MARK: - Private Methods

    @State
    private var isApplePayAvailable = false

    // MARK: - Private Methods

    private func updateApplePayAvailability() {
        isApplePayAvailable = PKPaymentAuthorizationController.canMakePayments() && Constants.merchantId != nil
    }
}
