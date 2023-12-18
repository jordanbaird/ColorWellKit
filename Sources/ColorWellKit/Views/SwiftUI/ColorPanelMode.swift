//
//  ColorPanelMode.swift
//  ColorWellKit
//

#if canImport(SwiftUI)
import SwiftUI

// MARK: - ColorPanelModeConfiguration

/// Values that configure the system color panel's mode.
@available(macOS 10.15, *)
public struct _ColorPanelModeConfiguration {
    /// The underlying color panel mode.
    let mode: NSColorPanel.Mode
}

// MARK: - ColorPanelMode

/// A type that specifies a mode for the system color panel.
@available(macOS 10.15, *)
public protocol ColorPanelMode {
    /// Values that configure the system color panel's mode.
    var _configuration: _ColorPanelModeConfiguration { get }
}

// MARK: - GrayscaleColorPanelMode

/// The grayscale color panel mode.
@available(macOS 10.15, *)
public struct GrayscaleColorPanelMode: ColorPanelMode {
    public let _configuration = _ColorPanelModeConfiguration(mode: .gray)

    /// Creates an instance of the grayscale color panel mode.
    public init() { }
}

@available(macOS 10.15, *)
extension ColorPanelMode where Self == GrayscaleColorPanelMode {
    /// The grayscale color panel mode.
    public static var gray: GrayscaleColorPanelMode {
        GrayscaleColorPanelMode()
    }
}

// MARK: - RGBColorPanelMode

/// The red-green-blue color panel mode.
@available(macOS 10.15, *)
public struct RGBColorPanelMode: ColorPanelMode {
    public let _configuration = _ColorPanelModeConfiguration(mode: .RGB)

    /// Creates an instance of the red-green-blue color panel mode.
    public init() { }
}

@available(macOS 10.15, *)
extension ColorPanelMode where Self == RGBColorPanelMode {
    /// The red-green-blue color panel mode.
    public static var rgb: RGBColorPanelMode {
        RGBColorPanelMode()
    }
}

// MARK: - CMYKColorPanelMode

/// The cyan-magenta-yellow-black color panel mode.
@available(macOS 10.15, *)
public struct CMYKColorPanelMode: ColorPanelMode {
    public let _configuration = _ColorPanelModeConfiguration(mode: .CMYK)

    /// Creates an instance of the cyan-magenta-yellow-black color panel mode.
    public init() { }
}

@available(macOS 10.15, *)
extension ColorPanelMode where Self == CMYKColorPanelMode {
    /// The cyan-magenta-yellow-black color panel mode.
    public static var cmyk: CMYKColorPanelMode {
        CMYKColorPanelMode()
    }
}

// MARK: - HSBColorPanelMode

/// The hue-saturation-brightness color panel mode.
@available(macOS 10.15, *)
public struct HSBColorPanelMode: ColorPanelMode {
    public let _configuration = _ColorPanelModeConfiguration(mode: .HSB)

    /// Creates an instance of the hue-saturation-brightness color panel mode.
    public init() { }
}

@available(macOS 10.15, *)
extension ColorPanelMode where Self == HSBColorPanelMode {
    /// The hue-saturation-brightness color panel mode.
    public static var hsb: HSBColorPanelMode {
        HSBColorPanelMode()
    }
}

// MARK: - CustomPaletteColorPanelMode

/// The custom palette color panel mode.
@available(macOS 10.15, *)
public struct CustomPaletteColorPanelMode: ColorPanelMode {
    public let _configuration = _ColorPanelModeConfiguration(mode: .customPalette)

    /// Creates an instance of the custom palette color panel mode.
    public init() { }
}

@available(macOS 10.15, *)
extension ColorPanelMode where Self == CustomPaletteColorPanelMode {
    /// The custom palette color panel mode.
    public static var customPalette: CustomPaletteColorPanelMode {
        CustomPaletteColorPanelMode()
    }
}

// MARK: - ColorListColorPanelMode

/// The color list color panel mode.
@available(macOS 10.15, *)
public struct ColorListColorPanelMode: ColorPanelMode {
    public let _configuration = _ColorPanelModeConfiguration(mode: .colorList)

    /// Creates an instance of the color list color panel mode.
    public init() { }
}

@available(macOS 10.15, *)
extension ColorPanelMode where Self == ColorListColorPanelMode {
    /// The color list color panel mode.
    public static var colorList: ColorListColorPanelMode {
        ColorListColorPanelMode()
    }
}

// MARK: - ColorWheelColorPanelMode

/// The color wheel color panel mode.
@available(macOS 10.15, *)
public struct ColorWheelColorPanelMode: ColorPanelMode {
    public let _configuration = _ColorPanelModeConfiguration(mode: .wheel)

    /// Creates an instance of the color wheel color panel mode.
    public init() { }
}

@available(macOS 10.15, *)
extension ColorPanelMode where Self == ColorWheelColorPanelMode {
    /// The color wheel color panel mode.
    public static var wheel: ColorWheelColorPanelMode {
        ColorWheelColorPanelMode()
    }
}

// MARK: - CrayonPickerColorPanelMode

/// The crayon picker color panel mode.
@available(macOS 10.15, *)
public struct CrayonPickerColorPanelMode: ColorPanelMode {
    public let _configuration = _ColorPanelModeConfiguration(mode: .crayon)

    /// Creates an instance of the crayon picker color panel mode.
    public init() { }
}

@available(macOS 10.15, *)
extension ColorPanelMode where Self == CrayonPickerColorPanelMode {
    /// The crayon picker color panel mode.
    public static var crayon: CrayonPickerColorPanelMode {
        CrayonPickerColorPanelMode()
    }
}
#endif
