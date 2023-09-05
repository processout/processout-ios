// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
public typealias AssetColorTypeAlias = ColorAsset.Color

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
public enum Asset {
  public enum Colors {
    public enum Action {
      public enum Border {
        public static let disabled = ColorAsset(name: "Action/Border/Disabled")
        public static let selected = ColorAsset(name: "Action/Border/Selected")
      }
      public enum Primary {
        public static let `default` = ColorAsset(name: "Action/Primary/Default")
        public static let disabled = ColorAsset(name: "Action/Primary/Disabled")
        public static let pressed = ColorAsset(name: "Action/Primary/Pressed")
      }
      public enum Secondary {
        public static let `default` = ColorAsset(name: "Action/Secondary/Default")
        public static let pressed = ColorAsset(name: "Action/Secondary/Pressed")
      }
    }
    public enum Border {
      public static let `default` = ColorAsset(name: "Border/Default")
      public static let divider = ColorAsset(name: "Border/Divider")
      public static let subtle = ColorAsset(name: "Border/Subtle")
    }
    public enum Surface {
      public static let background = ColorAsset(name: "Surface/Background")
      public static let error = ColorAsset(name: "Surface/Error")
      public static let level1 = ColorAsset(name: "Surface/Level1")
      public static let neutral = ColorAsset(name: "Surface/Neutral")
      public static let success = ColorAsset(name: "Surface/Success")
      public static let warning = ColorAsset(name: "Surface/Warning")
    }
    public enum Text {
      public static let disabled = ColorAsset(name: "Text/Disabled")
      public static let error = ColorAsset(name: "Text/Error")
      public static let muted = ColorAsset(name: "Text/Muted")
      public static let onColor = ColorAsset(name: "Text/OnColor")
      public static let primary = ColorAsset(name: "Text/Primary")
      public static let secondary = ColorAsset(name: "Text/Secondary")
      public static let success = ColorAsset(name: "Text/Success")
      public static let tertiary = ColorAsset(name: "Text/Tertiary")
      public static let warning = ColorAsset(name: "Text/Warning")
    }
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

public final class ColorAsset {
  public fileprivate(set) var name: String

  #if os(macOS)
  public typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  public private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  #if os(iOS) || os(tvOS)
  @available(iOS 11.0, tvOS 11.0, *)
  public func color(compatibleWith traitCollection: UITraitCollection) -> Color {
    let bundle = BundleLocator.bundle
    guard let color = Color(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  public private(set) lazy var swiftUIColor: SwiftUI.Color = {
    SwiftUI.Color(asset: self)
  }()
  #endif

  fileprivate init(name: String) {
    self.name = name
  }
}

public extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ColorAsset) {
    let bundle = BundleLocator.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
public extension SwiftUI.Color {
  init(asset: ColorAsset) {
    let bundle = BundleLocator.bundle
    self.init(asset.name, bundle: bundle)
  }
}
#endif
