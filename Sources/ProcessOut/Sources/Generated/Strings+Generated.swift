// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum Strings {

  internal enum NativeAlternativePayment {
    /// Pay with %@
    internal static func title(_ p1: Any) -> String {
      return Strings.tr("ProcessOut", "native-alternative-payment.title", String(describing: p1))
    }
    internal enum AwaitingCapture {
      /// To complete the payment please confirm it from your banking app.
      internal static var message: String { return Strings.tr("ProcessOut", "native-alternative-payment.awaiting-capture.message") }
    }
    internal enum CancelButton {
      /// Cancel
      internal static var title: String { return Strings.tr("ProcessOut", "native-alternative-payment.cancel-button.title") }
    }
    internal enum Email {
      /// name@example.com
      internal static var placeholder: String { return Strings.tr("ProcessOut", "native-alternative-payment.email.placeholder") }
    }
    internal enum Error {
      /// Email is not valid
      internal static var invalidEmail: String { return Strings.tr("ProcessOut", "native-alternative-payment.error.invalid-email") }
      /// Plural format key: "%#@length@"
      internal static func invalidLength(_ p1: Int) -> String {
        return Strings.tr("ProcessOut", "native-alternative-payment.error.invalid-length", p1)
      }
      /// Number is not valid
      internal static var invalidNumber: String { return Strings.tr("ProcessOut", "native-alternative-payment.error.invalid-number") }
      /// Phone number is not valid
      internal static var invalidPhone: String { return Strings.tr("ProcessOut", "native-alternative-payment.error.invalid-phone") }
      /// Value is not valid
      internal static var invalidText: String { return Strings.tr("ProcessOut", "native-alternative-payment.error.invalid-text") }
      /// Parameter is required
      internal static var requiredParameter: String { return Strings.tr("ProcessOut", "native-alternative-payment.error.required-parameter") }
    }
    internal enum Phone {
      /// Enter phone number
      internal static var placeholder: String { return Strings.tr("ProcessOut", "native-alternative-payment.phone.placeholder") }
    }
    internal enum SubmitButton {
      /// Pay
      internal static var defaultTitle: String { return Strings.tr("ProcessOut", "native-alternative-payment.submit-button.default-title") }
      /// Pay %@
      internal static func title(_ p1: Any) -> String {
        return Strings.tr("ProcessOut", "native-alternative-payment.submit-button.title", String(describing: p1))
      }
    }
    internal enum Success {
      /// Success!
      /// Payment approved
      internal static var message: String { return Strings.tr("ProcessOut", "native-alternative-payment.success.message") }
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension Strings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = Strings.localized(key, table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}
