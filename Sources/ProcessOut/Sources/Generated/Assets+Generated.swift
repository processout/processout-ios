// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetColorTypeAlias = ColorAsset.Color
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal enum Colors {
    internal enum Action {
      internal enum Border {
        internal static let disabled = ColorAsset(name: "Action/Border/Disabled")
        internal static let selected = ColorAsset(name: "Action/Border/Selected")
      }
      internal enum Primary {
        internal static let `default` = ColorAsset(name: "Action/Primary/Default")
        internal static let disabled = ColorAsset(name: "Action/Primary/Disabled")
        internal static let pressed = ColorAsset(name: "Action/Primary/Pressed")
      }
      internal enum Secondary {
        internal static let `default` = ColorAsset(name: "Action/Secondary/Default")
        internal static let pressed = ColorAsset(name: "Action/Secondary/Pressed")
      }
    }
    internal enum Border {
      internal static let `default` = ColorAsset(name: "Border/Default")
      internal static let divider = ColorAsset(name: "Border/Divider")
      internal static let subtle = ColorAsset(name: "Border/Subtle")
    }
    internal enum Surface {
      internal static let background = ColorAsset(name: "Surface/Background")
      internal static let error = ColorAsset(name: "Surface/Error")
      internal static let level1 = ColorAsset(name: "Surface/Level1")
      internal static let neutral = ColorAsset(name: "Surface/Neutral")
      internal static let success = ColorAsset(name: "Surface/Success")
      internal static let warning = ColorAsset(name: "Surface/Warning")
    }
    internal enum Text {
      internal static let disabled = ColorAsset(name: "Text/Disabled")
      internal static let error = ColorAsset(name: "Text/Error")
      internal static let muted = ColorAsset(name: "Text/Muted")
      internal static let onColor = ColorAsset(name: "Text/OnColor")
      internal static let primary = ColorAsset(name: "Text/Primary")
      internal static let secondary = ColorAsset(name: "Text/Secondary")
      internal static let success = ColorAsset(name: "Text/Success")
      internal static let tertiary = ColorAsset(name: "Text/Tertiary")
      internal static let warning = ColorAsset(name: "Text/Warning")
    }
  }
  internal enum Images {
    internal static let chevronDown = ImageAsset(name: "ChevronDown")
    internal static let success = ImageAsset(name: "Success")
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal final class ColorAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  internal private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  #if os(iOS) || os(tvOS)
  @available(iOS 11.0, tvOS 11.0, *)
  internal func color(compatibleWith traitCollection: UITraitCollection) -> Color {
    let bundle = BundleLocator.bundle
    guard let color = Color(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }
  #endif

  fileprivate init(name: String) {
    self.name = name
  }
}

internal extension ColorAsset.Color {
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

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  internal var image: Image {
    let bundle = BundleLocator.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if os(iOS) || os(tvOS)
  @available(iOS 8.0, tvOS 9.0, *)
  internal func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = BundleLocator.bundle
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif
}

internal extension ImageAsset.Image {
  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, *)
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleLocator.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}
