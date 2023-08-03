// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum Strings {
  internal enum CardTokenization {
    /// Add New Card
    internal static var title: String { return Strings.tr("ProcessOut", "card-tokenization.title", fallback: "Add New Card") }
    internal enum CancelButton {
      /// Cancel
      internal static var title: String { return Strings.tr("ProcessOut", "card-tokenization.cancel-button.title", fallback: "Cancel") }
    }
    internal enum CardDetails {
      /// Card Information
      internal static var title: String { return Strings.tr("ProcessOut", "card-tokenization.card-details.title", fallback: "Card Information") }
      internal enum Cvc {
        /// Cardholder Name
        internal static var cardholder: String { return Strings.tr("ProcessOut", "card-tokenization.card-details.cvc.cardholder", fallback: "Cardholder Name") }
        /// CVC
        internal static var placeholder: String { return Strings.tr("ProcessOut", "card-tokenization.card-details.cvc.placeholder", fallback: "CVC") }
      }
      internal enum Expiration {
        /// MM / YY
        internal static var placeholder: String { return Strings.tr("ProcessOut", "card-tokenization.card-details.expiration.placeholder", fallback: "MM / YY") }
      }
      internal enum Number {
        /// 4242 4242 4242 4242
        internal static var placeholder: String { return Strings.tr("ProcessOut", "card-tokenization.card-details.number.placeholder", fallback: "4242 4242 4242 4242") }
      }
    }
    internal enum SubmitButton {
      /// Submit
      internal static var title: String { return Strings.tr("ProcessOut", "card-tokenization.submit-button.title", fallback: "Submit") }
    }
  }
  internal enum NativeAlternativePayment {
    /// ProcessOut.strings
    ///   
    /// 
    ///   Created by Andrii Vysotskyi on 07.10.2022.
    internal static func title(_ p1: Any) -> String {
      return Strings.tr("ProcessOut", "native-alternative-payment.title", String(describing: p1), fallback: "Pay with %@")
    }
    internal enum CancelButton {
      /// Cancel
      internal static var title: String { return Strings.tr("ProcessOut", "native-alternative-payment.cancel-button.title", fallback: "Cancel") }
    }
    internal enum Email {
      /// name@example.com
      internal static var placeholder: String { return Strings.tr("ProcessOut", "native-alternative-payment.email.placeholder", fallback: "name@example.com") }
    }
    internal enum Error {
      /// Email is not valid
      internal static var invalidEmail: String { return Strings.tr("ProcessOut", "native-alternative-payment.error.invalid-email", fallback: "Email is not valid") }
      /// Plural format key: "%#@length@"
      internal static func invalidLength(_ p1: Int) -> String {
        return Strings.tr("ProcessOut", "native-alternative-payment.error.invalid-length", p1, fallback: "Plural format key: \"%#@length@\"")
      }
      /// Number is not valid
      internal static var invalidNumber: String { return Strings.tr("ProcessOut", "native-alternative-payment.error.invalid-number", fallback: "Number is not valid") }
      /// Phone number is not valid
      internal static var invalidPhone: String { return Strings.tr("ProcessOut", "native-alternative-payment.error.invalid-phone", fallback: "Phone number is not valid") }
      /// Value is not valid
      internal static var invalidValue: String { return Strings.tr("ProcessOut", "native-alternative-payment.error.invalid-value", fallback: "Value is not valid") }
      /// Parameter is required
      internal static var requiredParameter: String { return Strings.tr("ProcessOut", "native-alternative-payment.error.required-parameter", fallback: "Parameter is required") }
    }
    internal enum Phone {
      /// Enter phone number
      internal static var placeholder: String { return Strings.tr("ProcessOut", "native-alternative-payment.phone.placeholder", fallback: "Enter phone number") }
    }
    internal enum SubmitButton {
      /// Pay
      internal static var defaultTitle: String { return Strings.tr("ProcessOut", "native-alternative-payment.submit-button.default-title", fallback: "Pay") }
      /// Pay %@
      internal static func title(_ p1: Any) -> String {
        return Strings.tr("ProcessOut", "native-alternative-payment.submit-button.title", String(describing: p1), fallback: "Pay %@")
      }
    }
    internal enum Success {
      /// Success!
      /// Payment approved
      internal static var message: String { return Strings.tr("ProcessOut", "native-alternative-payment.success.message", fallback: "Success!\nPayment approved") }
    }
  }
  internal enum Test3DS {
    internal enum Challenge {
      /// Accept
      internal static var accept: String { return Strings.tr("ProcessOut", "test-3-d-s.challenge.accept", fallback: "Accept") }
      /// Reject
      internal static var reject: String { return Strings.tr("ProcessOut", "test-3-d-s.challenge.reject", fallback: "Reject") }
      /// Do you want to accept the 3DS2 challenge?
      internal static var title: String { return Strings.tr("ProcessOut", "test-3-d-s.challenge.title", fallback: "Do you want to accept the 3DS2 challenge?") }
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension Strings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = Strings.localized(key, table, value)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}
