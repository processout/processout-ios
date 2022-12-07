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
    internal enum Email {
      /// example@domain.com
      internal static var placeholder: String { return Strings.tr("ProcessOut", "native-alternative-payment.email.placeholder") }
    }
    internal enum Phone {
      /// Your phone number...
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
    internal enum Text {
      /// Lorem Ipsum...
      internal static var placeholder: String { return Strings.tr("ProcessOut", "native-alternative-payment.text.placeholder") }
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
