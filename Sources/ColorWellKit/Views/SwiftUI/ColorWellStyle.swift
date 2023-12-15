//
//  ColorWellStyle.swift
//  ColorWellKit
//

#if canImport(SwiftUI)

// MARK: - ColorWellStyleConfiguration

/// Values that configure a color well's style.
@available(macOS 10.15, *)
public struct _ColorWellStyleConfiguration {
    /// The underlying style of the color well.
    let style: ColorWell.Style
}

@available(macOS 10.15, *)
extension _ColorWellStyleConfiguration {
    static var `default`: _ColorWellStyleConfiguration {
        _ColorWellStyleConfiguration(style: ColorWell.BackingStorage.defaultStyle)
    }
}

@available(macOS 10.15, *)
extension _ColorWellStyleConfiguration: CustomStringConvertible {
    public var description: String {
        String(describing: style)
    }
}

// MARK: - ColorWellStyle

/// A type that specifies the appearance and behavior of a color well.
@available(macOS 10.15, *)
public protocol ColorWellStyle {
    /// Values that configure the color well's style.
    var _configuration: _ColorWellStyleConfiguration { get }
}

// MARK: - DefaultColorWellStyle

/// A color well style that displays the color well's color inside of a
/// rectangular control, and toggles the system color panel when clicked.
///
/// You can also use ``default`` to construct this style.
@available(macOS 10.15, *)
public struct DefaultColorWellStyle: ColorWellStyle {
    public let _configuration = _ColorWellStyleConfiguration(style: .default)

    /// Creates an instance of the default color well style.
    public init() { }
}

@available(macOS 10.15, *)
extension ColorWellStyle where Self == DefaultColorWellStyle {
    /// A color well style that displays the color well's color inside of a
    /// rectangular control, and toggles the system color panel when clicked.
    public static var `default`: DefaultColorWellStyle {
        DefaultColorWellStyle()
    }
}

// MARK: - MinimalColorWellStyle

/// A color well style that displays the color well's color inside of a
/// rectangular control, and shows a popover containing the color well's
/// swatch colors when clicked.
///
/// You can also use ``minimal`` to construct this style.
@available(macOS 10.15, *)
public struct MinimalColorWellStyle: ColorWellStyle {
    public let _configuration = _ColorWellStyleConfiguration(style: .minimal)

    /// Creates an instance of the minimal color well style.
    public init() { }
}

@available(macOS 10.15, *)
extension ColorWellStyle where Self == MinimalColorWellStyle {
    /// A color well style that displays the color well's color inside of a
    /// rectangular control, and shows a popover containing the color well's
    /// swatch colors when clicked.
    public static var minimal: MinimalColorWellStyle {
        MinimalColorWellStyle()
    }
}

// MARK: - ExpandedColorWellStyle

/// A color well style that displays the color well's color alongside
/// a dedicated button that toggles the system color panel.
///
/// Clicking inside the color area displays a popover containing the
/// color well's swatch colors.
///
/// You can also use ``expanded`` to construct this style.
@available(macOS 10.15, *)
public struct ExpandedColorWellStyle: ColorWellStyle {
    public let _configuration = _ColorWellStyleConfiguration(style: .expanded)

    /// Creates an instance of the expanded color well style.
    public init() { }
}

@available(macOS 10.15, *)
extension ColorWellStyle where Self == ExpandedColorWellStyle {
    /// A color well style that displays the color well's color alongside
    /// a dedicated button that toggles the system color panel.
    ///
    /// Clicking inside the color area displays a popover containing the
    /// color well's swatch colors.
    public static var expanded: ExpandedColorWellStyle {
        ExpandedColorWellStyle()
    }
}
#endif
