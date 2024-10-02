// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen
// todo(andrii-vysotskyi): remove before releasing 5.0.0

#if os(macOS)
  import AppKit.NSFont
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIFont
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "FontConvertible.Font", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias Font = FontConvertible.Font

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Fonts

// swiftlint:disable identifier_name line_length type_body_length
internal enum FontFamily {
  internal enum WorkSans {
    internal static let italic = FontConvertible(name: "WorkSans-Italic", family: "Work Sans", path: "WorkSans-Italic.ttf")
    internal static let regular = FontConvertible(name: "WorkSans-Regular", family: "Work Sans", path: "WorkSans.ttf")
    internal static let blackItalic = FontConvertible(name: "WorkSansItalic-Black", family: "Work Sans", path: "WorkSans-Italic.ttf")
    internal static let boldItalic = FontConvertible(name: "WorkSansItalic-Bold", family: "Work Sans", path: "WorkSans-Italic.ttf")
    internal static let extraBoldItalic = FontConvertible(name: "WorkSansItalic-ExtraBold", family: "Work Sans", path: "WorkSans-Italic.ttf")
    internal static let extraLightItalic = FontConvertible(name: "WorkSansItalic-ExtraLight", family: "Work Sans", path: "WorkSans-Italic.ttf")
    internal static let lightItalic = FontConvertible(name: "WorkSansItalic-Light", family: "Work Sans", path: "WorkSans-Italic.ttf")
    internal static let mediumItalic = FontConvertible(name: "WorkSansItalic-Medium", family: "Work Sans", path: "WorkSans-Italic.ttf")
    internal static let semiBoldItalic = FontConvertible(name: "WorkSansItalic-SemiBold", family: "Work Sans", path: "WorkSans-Italic.ttf")
    internal static let thinItalic = FontConvertible(name: "WorkSansItalic-Thin", family: "Work Sans", path: "WorkSans-Italic.ttf")
    internal static let black = FontConvertible(name: "WorkSansRoman-Black", family: "Work Sans", path: "WorkSans.ttf")
    internal static let bold = FontConvertible(name: "WorkSansRoman-Bold", family: "Work Sans", path: "WorkSans.ttf")
    internal static let extraBold = FontConvertible(name: "WorkSansRoman-ExtraBold", family: "Work Sans", path: "WorkSans.ttf")
    internal static let extraLight = FontConvertible(name: "WorkSansRoman-ExtraLight", family: "Work Sans", path: "WorkSans.ttf")
    internal static let light = FontConvertible(name: "WorkSansRoman-Light", family: "Work Sans", path: "WorkSans.ttf")
    internal static let medium = FontConvertible(name: "WorkSansRoman-Medium", family: "Work Sans", path: "WorkSans.ttf")
    internal static let semiBold = FontConvertible(name: "WorkSansRoman-SemiBold", family: "Work Sans", path: "WorkSans.ttf")
    internal static let thin = FontConvertible(name: "WorkSansRoman-Thin", family: "Work Sans", path: "WorkSans.ttf")
    internal static let all: [FontConvertible] = [italic, regular, blackItalic, boldItalic, extraBoldItalic, extraLightItalic, lightItalic, mediumItalic, semiBoldItalic, thinItalic, black, bold, extraBold, extraLight, light, medium, semiBold, thin]
  }
  internal static let allCustomFonts: [FontConvertible] = [WorkSans.all].flatMap { $0 }
  internal static func registerAllCustomFonts() {
    allCustomFonts.forEach { $0.registerIfNeeded() }
  }
}
// swiftlint:enable identifier_name line_length type_body_length

// MARK: - Implementation Details

internal struct FontConvertible {
  internal let name: String
  internal let family: String
  internal let path: String

  #if os(macOS)
  internal typealias Font = NSFont
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Font = UIFont
  #endif

  internal func font(size: CGFloat) -> Font {
    guard let font = Font(font: self, size: size) else {
      fatalError("Unable to initialize font '\(name)' (\(family))")
    }
    return font
  }

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal func swiftUIFont(size: CGFloat) -> SwiftUI.Font {
    return SwiftUI.Font.custom(self, size: size)
  }

  @available(iOS 14.0, tvOS 14.0, watchOS 7.0, macOS 11.0, *)
  internal func swiftUIFont(fixedSize: CGFloat) -> SwiftUI.Font {
    return SwiftUI.Font.custom(self, fixedSize: fixedSize)
  }

  @available(iOS 14.0, tvOS 14.0, watchOS 7.0, macOS 11.0, *)
  internal func swiftUIFont(size: CGFloat, relativeTo textStyle: SwiftUI.Font.TextStyle) -> SwiftUI.Font {
    return SwiftUI.Font.custom(self, size: size, relativeTo: textStyle)
  }
  #endif

  internal func register() {
    // swiftlint:disable:next conditional_returns_on_newline
    guard let url = url else { return }
    CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
  }

  fileprivate func registerIfNeeded() {
    #if os(iOS) || os(tvOS) || os(watchOS)
    if !UIFont.fontNames(forFamilyName: family).contains(name) {
      register()
    }
    #elseif os(macOS)
    if let url = url, CTFontManagerGetScopeForURL(url as CFURL) == .none {
      register()
    }
    #endif
  }

  fileprivate var url: URL? {
    // swiftlint:disable:next implicit_return
    return BundleLocator.bundle.url(forResource: path, withExtension: nil)
  }
}

internal extension FontConvertible.Font {
  convenience init?(font: FontConvertible, size: CGFloat) {
    font.registerIfNeeded()
    self.init(name: font.name, size: size)
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Font {
  static func custom(_ font: FontConvertible, size: CGFloat) -> SwiftUI.Font {
    font.registerIfNeeded()
    return custom(font.name, size: size)
  }
}

@available(iOS 14.0, tvOS 14.0, watchOS 7.0, macOS 11.0, *)
internal extension SwiftUI.Font {
  static func custom(_ font: FontConvertible, fixedSize: CGFloat) -> SwiftUI.Font {
    font.registerIfNeeded()
    return custom(font.name, fixedSize: fixedSize)
  }

  static func custom(
    _ font: FontConvertible,
    size: CGFloat,
    relativeTo textStyle: SwiftUI.Font.TextStyle
  ) -> SwiftUI.Font {
    font.registerIfNeeded()
    return custom(font.name, size: size, relativeTo: textStyle)
  }
}
#endif
