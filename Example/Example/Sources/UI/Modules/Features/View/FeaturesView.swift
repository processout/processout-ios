//
//  FeaturesViewController.swift
//  Example
//
//  Created by Andrii Vysotskyi on 28.10.2022.
//

import SwiftUI
import ProcessOutUI

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
                NavigationLink(String(localized: .Features.applicationSettings)) {
                    ConfigurationView()
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(String(localized: .Features.title))
    }

    // MARK: - Private Methods

    private var isApplePayAvailable: Bool {
        POPassKitPaymentAuthorizationController.canMakePayments() && Constants.merchantId != nil
    }
}
