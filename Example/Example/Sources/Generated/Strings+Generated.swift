// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen
// todo(andrii-vysotskyi): remove

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum Strings {
  internal enum AlternativePaymentData {
    /// There is no additional data yet, press add button to add more. Additional data is required only for some payment providers, if it's not the case simply continue.
    internal static let emptyMessage = Strings.tr("Localizable", "alternative-payment-data.empty-message", fallback: "There is no additional data yet, press add button to add more. Additional data is required only for some payment providers, if it's not the case simply continue.")
    /// Remove
    internal static let remove = Strings.tr("Localizable", "alternative-payment-data.remove", fallback: "Remove")
    /// Additional data
    internal static let title = Strings.tr("Localizable", "alternative-payment-data.title", fallback: "Additional data")
  }
  internal enum AlternativePaymentDataEntry {
    /// Confirm
    internal static let confirm = Strings.tr("Localizable", "alternative-payment-data-entry.confirm", fallback: "Confirm")
    /// Please enter additional data details
    internal static let message = Strings.tr("Localizable", "alternative-payment-data-entry.message", fallback: "Please enter additional data details")
    internal enum Key {
      /// Key
      internal static let placeholder = Strings.tr("Localizable", "alternative-payment-data-entry.key.placeholder", fallback: "Key")
    }
    internal enum Value {
      /// Value
      internal static let placeholder = Strings.tr("Localizable", "alternative-payment-data-entry.value.placeholder", fallback: "Value")
    }
  }
  internal enum AlternativePaymentMethods {
    /// Alternative Payment Methods
    internal static let title = Strings.tr("Localizable", "alternative-payment-methods.title", fallback: "Alternative Payment Methods")
    internal enum Failure {
      /// Something went wrong...
      internal static let unknown = Strings.tr("Localizable", "alternative-payment-methods.failure.unknown", fallback: "Something went wrong...")
    }
    internal enum Gateway {
      /// <Unknown>
      internal static let unknown = Strings.tr("Localizable", "alternative-payment-methods.gateway.unknown", fallback: "<Unknown>")
    }
    internal enum Result {
      /// Continue
      internal static let `continue` = Strings.tr("Localizable", "alternative-payment-methods.result.continue", fallback: "Continue")
      /// Payment did fail.
      internal static let defaultFailureMessage = Strings.tr("Localizable", "alternative-payment-methods.result.default-failure-message", fallback: "Payment did fail.")
      /// Payment did fail with error: '%@'.
      internal static func failureMessage(_ p1: Any) -> String {
        return Strings.tr("Localizable", "alternative-payment-methods.result.failure-message", String(describing: p1), fallback: "Payment did fail with error: '%@'.")
      }
    }
  }
  internal enum AuthorizationAmount {
    /// Confirm
    internal static let confirm = Strings.tr("Localizable", "authorization-amount.confirm", fallback: "Confirm")
    /// Please select amount and currency.
    internal static let message = Strings.tr("Localizable", "authorization-amount.message", fallback: "Please select amount and currency.")
    internal enum Amount {
      /// Amount
      internal static let placeholder = Strings.tr("Localizable", "authorization-amount.amount.placeholder", fallback: "Amount")
    }
    internal enum Currency {
      /// Currency Code
      internal static let placeholder = Strings.tr("Localizable", "authorization-amount.currency.placeholder", fallback: "Currency Code")
    }
  }
  internal enum Features {
    /// Continue
    internal static let `continue` = Strings.tr("Localizable", "features.continue", fallback: "Continue")
    /// Localizable.strings
    ///   Example
    /// 
    ///   Created by Andrii Vysotskyi on 17.07.2022.
    internal static let title = Strings.tr("Localizable", "features.title", fallback: "Available Features")
    internal enum AlternativePayment {
      /// Alternative Payment
      internal static let title = Strings.tr("Localizable", "features.alternative-payment.title", fallback: "Alternative Payment")
    }
    internal enum ApplePay {
      /// Apple Pay
      internal static let title = Strings.tr("Localizable", "features.apple-pay.title", fallback: "Apple Pay")
    }
    internal enum CardPayment {
      /// Card tokenization did fail with error: '%@'.
      internal static func error(_ p1: Any) -> String {
        return Strings.tr("Localizable", "features.card-payment.error", String(describing: p1), fallback: "Card tokenization did fail with error: '%@'.")
      }
      /// Unable to tokenize card.
      internal static let errorGeneric = Strings.tr("Localizable", "features.card-payment.error-generic", fallback: "Unable to tokenize card.")
      /// Card %@ was successfully tokenized.
      internal static func success(_ p1: Any) -> String {
        return Strings.tr("Localizable", "features.card-payment.success", String(describing: p1), fallback: "Card %@ was successfully tokenized.")
      }
      /// Card payment
      internal static let title = Strings.tr("Localizable", "features.card-payment.title", fallback: "Card payment")
      internal enum Checkout {
        /// Card payment [Checkout 3DS SDK]
        internal static let title = Strings.tr("Localizable", "features.card-payment.checkout.title", fallback: "Card payment [Checkout 3DS SDK]")
      }
    }
    internal enum DynamicCheckout {
      /// Dynamic Checkout (Beta)
      internal static let title = Strings.tr("Localizable", "features.dynamic-checkout.title", fallback: "Dynamic Checkout (Beta)")
    }
    internal enum NativeAlternativePayment {
      /// Native Alternative Payment
      internal static let title = Strings.tr("Localizable", "features.native-alternative-payment.title", fallback: "Native Alternative Payment")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension Strings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
