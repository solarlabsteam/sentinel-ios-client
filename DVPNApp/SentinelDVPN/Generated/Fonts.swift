// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(OSX)
  import AppKit.NSFont
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIFont
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "FontConvertible.Font", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias Font = FontConvertible.Font

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Fonts

// swiftlint:disable identifier_name line_length type_body_length
internal enum FontFamily {
  internal enum Poppins {
    internal static let black = FontConvertible(name: "Poppins-Black", family: "Poppins", path: "Poppins-Black.ttf")
    internal static let blackItalic = FontConvertible(name: "Poppins-BlackItalic", family: "Poppins", path: "Poppins-BlackItalic.ttf")
    internal static let bold = FontConvertible(name: "Poppins-Bold", family: "Poppins", path: "Poppins-Bold.ttf")
    internal static let boldItalic = FontConvertible(name: "Poppins-BoldItalic", family: "Poppins", path: "Poppins-BoldItalic.ttf")
    internal static let extraBold = FontConvertible(name: "Poppins-ExtraBold", family: "Poppins", path: "Poppins-ExtraBold.ttf")
    internal static let extraBoldItalic = FontConvertible(name: "Poppins-ExtraBoldItalic", family: "Poppins", path: "Poppins-ExtraBoldItalic.ttf")
    internal static let extraLight = FontConvertible(name: "Poppins-ExtraLight", family: "Poppins", path: "Poppins-ExtraLight.ttf")
    internal static let extraLightItalic = FontConvertible(name: "Poppins-ExtraLightItalic", family: "Poppins", path: "Poppins-ExtraLightItalic.ttf")
    internal static let italic = FontConvertible(name: "Poppins-Italic", family: "Poppins", path: "Poppins-Italic.ttf")
    internal static let light = FontConvertible(name: "Poppins-Light", family: "Poppins", path: "Poppins-Light.ttf")
    internal static let lightItalic = FontConvertible(name: "Poppins-LightItalic", family: "Poppins", path: "Poppins-LightItalic.ttf")
    internal static let medium = FontConvertible(name: "Poppins-Medium", family: "Poppins", path: "Poppins-Medium.ttf")
    internal static let mediumItalic = FontConvertible(name: "Poppins-MediumItalic", family: "Poppins", path: "Poppins-MediumItalic.ttf")
    internal static let regular = FontConvertible(name: "Poppins-Regular", family: "Poppins", path: "Poppins-Regular.ttf")
    internal static let semiBold = FontConvertible(name: "Poppins-SemiBold", family: "Poppins", path: "Poppins-SemiBold.ttf")
    internal static let semiBoldItalic = FontConvertible(name: "Poppins-SemiBoldItalic", family: "Poppins", path: "Poppins-SemiBoldItalic.ttf")
    internal static let thin = FontConvertible(name: "Poppins-Thin", family: "Poppins", path: "Poppins-Thin.ttf")
    internal static let thinItalic = FontConvertible(name: "Poppins-ThinItalic", family: "Poppins", path: "Poppins-ThinItalic.ttf")
    internal static let all: [FontConvertible] = [black, blackItalic, bold, boldItalic, extraBold, extraBoldItalic, extraLight, extraLightItalic, italic, light, lightItalic, medium, mediumItalic, regular, semiBold, semiBoldItalic, thin, thinItalic]
  }
  internal static let allCustomFonts: [FontConvertible] = [Poppins.all].flatMap { $0 }
  internal static func registerAllCustomFonts() {
    allCustomFonts.forEach { $0.register() }
  }
}
// swiftlint:enable identifier_name line_length type_body_length

// MARK: - Implementation Details

internal struct FontConvertible {
  internal let name: String
  internal let family: String
  internal let path: String

  #if os(OSX)
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

  internal func register() {
    // swiftlint:disable:next conditional_returns_on_newline
    guard let url = url else { return }
    CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
  }

  fileprivate var url: URL? {
    // swiftlint:disable:next implicit_return
    return BundleToken.bundle.url(forResource: path, withExtension: nil)
  }
}

internal extension FontConvertible.Font {
  convenience init?(font: FontConvertible, size: CGFloat) {
    #if os(iOS) || os(tvOS) || os(watchOS)
    if !UIFont.fontNames(forFamilyName: font.family).contains(font.name) {
      font.register()
    }
    #elseif os(OSX)
    if let url = font.url, CTFontManagerGetScopeForURL(url as CFURL) == .none {
      font.register()
    }
    #endif

    self.init(name: font.name, size: size)
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
