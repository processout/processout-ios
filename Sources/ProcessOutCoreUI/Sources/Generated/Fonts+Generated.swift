// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

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
public typealias _Font = FontConvertible.Font

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Fonts

// swiftlint:disable identifier_name line_length type_body_length
public enum FontFamily {
  public enum WorkSans {
    public static let italic = FontConvertible(name: "WorkSans-Italic", family: "Work Sans", path: "WorkSans-Italic.ttf")
    public static let regular = FontConvertible(name: "WorkSans-Regular", family: "Work Sans", path: "WorkSans.ttf")
    public static let blackItalic = FontConvertible(name: "WorkSansItalic-Black", family: "Work Sans", path: "WorkSans-Italic.ttf")
    public static let boldItalic = FontConvertible(name: "WorkSansItalic-Bold", family: "Work Sans", path: "WorkSans-Italic.ttf")
    public static let extraBoldItalic = FontConvertible(name: "WorkSansItalic-ExtraBold", family: "Work Sans", path: "WorkSans-Italic.ttf")
    public static let extraLightItalic = FontConvertible(name: "WorkSansItalic-ExtraLight", family: "Work Sans", path: "WorkSans-Italic.ttf")
    public static let lightItalic = FontConvertible(name: "WorkSansItalic-Light", family: "Work Sans", path: "WorkSans-Italic.ttf")
    public static let mediumItalic = FontConvertible(name: "WorkSansItalic-Medium", family: "Work Sans", path: "WorkSans-Italic.ttf")
    public static let semiBoldItalic = FontConvertible(name: "WorkSansItalic-SemiBold", family: "Work Sans", path: "WorkSans-Italic.ttf")
    public static let thinItalic = FontConvertible(name: "WorkSansItalic-Thin", family: "Work Sans", path: "WorkSans-Italic.ttf")
    public static let black = FontConvertible(name: "WorkSansRoman-Black", family: "Work Sans", path: "WorkSans.ttf")
    public static let bold = FontConvertible(name: "WorkSansRoman-Bold", family: "Work Sans", path: "WorkSans.ttf")
    public static let extraBold = FontConvertible(name: "WorkSansRoman-ExtraBold", family: "Work Sans", path: "WorkSans.ttf")
    public static let extraLight = FontConvertible(name: "WorkSansRoman-ExtraLight", family: "Work Sans", path: "WorkSans.ttf")
    public static let light = FontConvertible(name: "WorkSansRoman-Light", family: "Work Sans", path: "WorkSans.ttf")
    public static let medium = FontConvertible(name: "WorkSansRoman-Medium", family: "Work Sans", path: "WorkSans.ttf")
    public static let semiBold = FontConvertible(name: "WorkSansRoman-SemiBold", family: "Work Sans", path: "WorkSans.ttf")
    public static let thin = FontConvertible(name: "WorkSansRoman-Thin", family: "Work Sans", path: "WorkSans.ttf")
    public static let all: [FontConvertible] = [italic, regular, blackItalic, boldItalic, extraBoldItalic, extraLightItalic, lightItalic, mediumItalic, semiBoldItalic, thinItalic, black, bold, extraBold, extraLight, light, medium, semiBold, thin]
  }
  public static let allCustomFonts: [FontConvertible] = [WorkSans.all].flatMap { $0 }
  public static func registerAllCustomFonts() {
    allCustomFonts.forEach { $0.register() }
  }
}
// swiftlint:enable identifier_name line_length type_body_length

// MARK: - Implementation Details

public struct FontConvertible {
  public let name: String
  public let family: String
  public let path: String

  #if os(macOS)
  public typealias Font = NSFont
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Font = UIFont
  #endif

  public func font(size: CGFloat) -> Font {
    guard let font = Font(font: self, size: size) else {
      fatalError("Unable to initialize font '\(name)' (\(family))")
    }
    return font
  }

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  public func swiftUIFont(size: CGFloat) -> SwiftUI.Font {
    return SwiftUI.Font.custom(self, size: size)
  }

  @available(iOS 14.0, tvOS 14.0, watchOS 7.0, macOS 11.0, *)
  public func swiftUIFont(fixedSize: CGFloat) -> SwiftUI.Font {
    return SwiftUI.Font.custom(self, fixedSize: fixedSize)
  }

  @available(iOS 14.0, tvOS 14.0, watchOS 7.0, macOS 11.0, *)
  public func swiftUIFont(size: CGFloat, relativeTo textStyle: SwiftUI.Font.TextStyle) -> SwiftUI.Font {
    return SwiftUI.Font.custom(self, size: size, relativeTo: textStyle)
  }
  #endif

  public func register() {
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

public extension FontConvertible.Font {
  convenience init?(font: FontConvertible, size: CGFloat) {
    font.registerIfNeeded()
    self.init(name: font.name, size: size)
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
public extension SwiftUI.Font {
  static func custom(_ font: FontConvertible, size: CGFloat) -> SwiftUI.Font {
    font.registerIfNeeded()
    return custom(font.name, size: size)
  }
}

@available(iOS 14.0, tvOS 14.0, watchOS 7.0, macOS 11.0, *)
public extension SwiftUI.Font {
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
