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
    internal enum Background {
      internal enum Grey {
        internal static let dark = ColorAsset(name: "Background/Grey/Dark")
        internal static let light = ColorAsset(name: "Background/Grey/Light")
      }
      internal static let input = ColorAsset(name: "Background/Input")
      internal static let primary = ColorAsset(name: "Background/Primary")
      internal enum Success {
        internal static let dark = ColorAsset(name: "Background/Success/Dark")
        internal static let darker = ColorAsset(name: "Background/Success/Darker")
        internal static let light = ColorAsset(name: "Background/Success/Light")
      }
    }
    internal enum Border {
      internal static let active = ColorAsset(name: "Border/Active")
      internal static let error = ColorAsset(name: "Border/Error")
      internal static let primary = ColorAsset(name: "Border/Primary")
    }
    internal enum Button {
      internal static let border = ColorAsset(name: "Button/Border")
      internal static let disabled = ColorAsset(name: "Button/Disabled")
      internal static let highlighted = ColorAsset(name: "Button/Highlighted")
      internal static let primary = ColorAsset(name: "Button/Primary")
      internal enum Text {
        internal static let primary = ColorAsset(name: "Button/Text/Primary")
        internal static let secondary = ColorAsset(name: "Button/Text/Secondary")
      }
    }
    internal enum Generic {
      internal static let black = ColorAsset(name: "Generic/Black")
      internal static let white = ColorAsset(name: "Generic/White")
    }
    internal enum Icon {
      internal static let primary = ColorAsset(name: "Icon/Primary")
    }
    internal enum New {
      internal enum Action {
        internal enum Border {
          internal static let disabled = ColorAsset(name: "New/Action/Border/Disabled")
          internal static let hover = ColorAsset(name: "New/Action/Border/Hover")
          internal static let selected = ColorAsset(name: "New/Action/Border/Selected")
        }
        internal enum Primary {
          internal static let `default` = ColorAsset(name: "New/Action/Primary/Default")
          internal static let disabled = ColorAsset(name: "New/Action/Primary/Disabled")
          internal static let hover = ColorAsset(name: "New/Action/Primary/Hover")
          internal static let pressed = ColorAsset(name: "New/Action/Primary/Pressed")
        }
        internal enum Secondary {
          internal static let `default` = ColorAsset(name: "New/Action/Secondary/Default")
          internal static let hover = ColorAsset(name: "New/Action/Secondary/Hover")
          internal static let pressed = ColorAsset(name: "New/Action/Secondary/Pressed")
        }
      }
      internal enum Border {
        internal static let `default` = ColorAsset(name: "New/Border/Default")
        internal static let divider = ColorAsset(name: "New/Border/Divider")
        internal static let subtle = ColorAsset(name: "New/Border/Subtle")
      }
      internal enum Interactive {
        internal static let focus = ColorAsset(name: "New/Interactive/Focus")
        internal static let link = ColorAsset(name: "New/Interactive/Link")
      }
      internal enum Navigation {
        internal enum Background {
          internal static let hover = ColorAsset(name: "New/Navigation/Background/Hover")
          internal static let selected = ColorAsset(name: "New/Navigation/Background/Selected")
        }
      }
      internal enum ProjectMenu {
        internal enum Background {
          internal static let `default` = ColorAsset(name: "New/ProjectMenu/Background/Default")
          internal static let list = ColorAsset(name: "New/ProjectMenu/Background/List")
        }
        internal static let hover = ColorAsset(name: "New/ProjectMenu/Hover")
        internal static let selected = ColorAsset(name: "New/ProjectMenu/Selected")
      }
      internal enum Surface {
        internal static let background = ColorAsset(name: "New/Surface/Background")
        internal static let error = ColorAsset(name: "New/Surface/Error")
        internal static let level1 = ColorAsset(name: "New/Surface/Level1")
        internal static let neutral = ColorAsset(name: "New/Surface/Neutral")
        internal static let success = ColorAsset(name: "New/Surface/Success")
        internal static let warning = ColorAsset(name: "New/Surface/Warning")
      }
      internal enum Tables {
        internal static let highlight = ColorAsset(name: "New/Tables/Highlight")
        internal enum RowBorder {
          internal static let `default` = ColorAsset(name: "New/Tables/RowBorder/Default")
          internal static let selected = ColorAsset(name: "New/Tables/RowBorder/Selected")
        }
      }
      internal enum Tags {
        internal enum Background {
          internal static let `default` = ColorAsset(name: "New/Tags/Background/Default")
        }
      }
      internal enum Text {
        internal static let disabled = ColorAsset(name: "New/Text/Disabled")
        internal static let error = ColorAsset(name: "New/Text/Error")
        internal static let muted = ColorAsset(name: "New/Text/Muted")
        internal static let onColor = ColorAsset(name: "New/Text/OnColor")
        internal static let primary = ColorAsset(name: "New/Text/Primary")
        internal static let secondary = ColorAsset(name: "New/Text/Secondary")
        internal static let success = ColorAsset(name: "New/Text/Success")
        internal static let tertiary = ColorAsset(name: "New/Text/Tertiary")
        internal static let warning = ColorAsset(name: "New/Text/Warning")
      }
      internal enum Timelines {
        internal static let error = ColorAsset(name: "New/Timelines/Error")
        internal static let neutral = ColorAsset(name: "New/Timelines/Neutral")
        internal static let success = ColorAsset(name: "New/Timelines/Success")
        internal static let warning = ColorAsset(name: "New/Timelines/Warning")
      }
      internal enum Toggle {
        internal enum Background {
          internal static let `default` = ColorAsset(name: "New/Toggle/Background/Default")
          internal static let on = ColorAsset(name: "New/Toggle/Background/On")
        }
      }
    }
    internal enum Text {
      internal static let disabled = ColorAsset(name: "Text/Disabled")
      internal static let error = ColorAsset(name: "Text/Error")
      internal static let link = ColorAsset(name: "Text/Link")
      internal static let primary = ColorAsset(name: "Text/Primary")
      internal static let secondary = ColorAsset(name: "Text/Secondary")
      internal static let success = ColorAsset(name: "Text/Success")
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
