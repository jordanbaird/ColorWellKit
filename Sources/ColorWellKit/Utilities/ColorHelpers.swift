//
//  ColorHelpers.swift
//  ColorWellKit
//

import AppKit

// MARK: - ColorInfo

/// Container for color type and component information.
struct ColorInfo: CustomStringConvertible {
    /// Color type information.
    private enum ColorType: CustomStringConvertible {
        case componentBased(components: ColorComponents)
        case pattern(image: NSImage)
        case catalog(name: String)
        case unknown(color: NSColor)
        case deviceN
        case indexed
        case lab

        var description: String {
            switch self {
            case .componentBased(let components):
                switch components {
                case .rgb: "rgb"
                case .cmyk: "cmyk"
                case .grayscale: "grayscale"
                case .other: "component-based color"
                case .invalid: "invalid"
                }
            case .pattern: "pattern image"
            case .catalog: "catalog color"
            case .unknown: "unknown color space"
            case .deviceN: "deviceN"
            case .indexed: "indexed"
            case .lab: "L*a*b*"
            }
        }
    }

    /// Color component information.
    private enum ColorComponents {
        case rgb(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)
        case cmyk(cyan: CGFloat, magenta: CGFloat, yellow: CGFloat, black: CGFloat, alpha: CGFloat)
        case grayscale(white: CGFloat, alpha: CGFloat)
        case other(components: [CGFloat])
        case invalid

        init(color: NSColor) {
            switch color.colorSpace.colorSpaceModel {
            case _ where color.type != .componentBased:
                cw_log(
                    "Attempted to get the components for a non component-based color",
                    category: .components,
                    type: .error
                )
                self = .invalid
            case .rgb:
                self = .rgb(
                    red: color.redComponent,
                    green: color.greenComponent,
                    blue: color.blueComponent,
                    alpha: color.alphaComponent
                )
            case .cmyk:
                self = .cmyk(
                    cyan: color.cyanComponent,
                    magenta: color.magentaComponent,
                    yellow: color.yellowComponent,
                    black: color.blackComponent,
                    alpha: color.alphaComponent
                )
            case .gray:
                self = .grayscale(
                    white: color.whiteComponent,
                    alpha: color.alphaComponent
                )
            default:
                var components = [CGFloat](repeating: 0, count: color.numberOfComponents)
                color.getComponents(&components)
                self = .other(components: components)
            }
        }
    }

    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 6
        return formatter
    }()

    private let type: ColorType

    /// The raw components extracted from this instance.
    var extractedComponents: [Any] {
        switch type {
        case .componentBased(let components):
            switch components {
            case .rgb(let red, let green, let blue, let alpha):
                [red, green, blue, alpha]
            case .cmyk(let cyan, let magenta, let yellow, let black, let alpha):
                [cyan, magenta, yellow, black, alpha]
            case .grayscale(let white, let alpha):
                [white, alpha]
            case .other(let components):
                components
            case .invalid:
                []
            }
        case .pattern(let image):
            [image]
        case .catalog(let name):
            [name]
        case .unknown(let color):
            [String(describing: color)]
        default:
            []
        }
    }

    /// String representations of the components extracted from this instance.
    var extractedComponentStrings: [String] {
        extractedComponents.compactMap { component in
            if let component = component as? NSNumber {
                Self.formatter.string(from: component)
            } else {
                String(describing: component)
            }
        }
    }

    var description: String {
        "\(type) \(extractedComponentStrings.joined(separator: " "))"
    }

    /// Creates an instance from the specified color.
    init(color: NSColor) {
        self.type = switch color.type {
        case .componentBased: .componentBased(components: ColorComponents(color: color))
        case .pattern: .pattern(image: color.patternImage)
        case .catalog: .catalog(name: color.localizedColorNameComponent)
        @unknown default: .unknown(color: color)
        }
    }
}

// MARK: - ColorScheme

/// A value corresponding to a light or dark appearance.
enum ColorScheme {
    /// A color scheme that indicates a light appearance.
    case light
    /// A color scheme that indicates a dark appearance.
    case dark

    /// The names of the light appearances used by the system.
    private static let systemLightAppearanceNames: Set<NSAppearance.Name> = {
        var result: Set<NSAppearance.Name> = [
            .aqua,
            .vibrantLight,
        ]
        if #available(macOS 10.14, *) {
            result.formUnion([
                .accessibilityHighContrastAqua,
                .accessibilityHighContrastVibrantLight,
            ])
        }
        return result
    }()

    /// The names of the dark appearances used by the system.
    private static let systemDarkAppearanceNames: Set<NSAppearance.Name> = {
        var result: Set<NSAppearance.Name> = [
            .vibrantDark,
        ]
        if #available(macOS 10.14, *) {
            result.formUnion([
                .darkAqua,
                .accessibilityHighContrastDarkAqua,
                .accessibilityHighContrastVibrantDark,
            ])
        }
        return result
    }()

    /// Returns the color scheme that exactly matches the given appearance,
    /// or `nil` if the color scheme cannot be determined.
    private static func exactMatch(for appearance: NSAppearance) -> ColorScheme? {
        let name = appearance.name
        if systemDarkAppearanceNames.contains(name) {
            return .dark
        }
        if systemLightAppearanceNames.contains(name) {
            return .light
        }
        return nil
    }

    /// Returns the color scheme that best matches the given appearance,
    /// or `nil` if the color scheme cannot be determined.
    private static func bestMatch(for appearance: NSAppearance) -> ColorScheme? {
        let lowercased = appearance.name.rawValue.lowercased()
        if lowercased.contains("dark") {
            return .dark
        }
        if lowercased.contains("light") || lowercased.contains("aqua") {
            return .light
        }
        return nil
    }

    /// Returns the color scheme of the given appearance.
    ///
    /// If a color scheme cannot be found that matches the given appearance,
    /// the `light` color scheme is returned.
    private static func colorScheme(for appearance: NSAppearance) -> ColorScheme {
        if let match = exactMatch(for: appearance) {
            return match
        }
        if let match = bestMatch(for: appearance) {
            return match
        }
        return .light
    }

    /// Returns the color scheme of the current appearance.
    ///
    /// If a color scheme cannot be found that matches the given appearance,
    /// the `light` color scheme is returned.
    static var current: ColorScheme {
        if #available(macOS 11.0, *) {
            return colorScheme(for: .currentDrawing())
        } else {
            return colorScheme(for: .current)
        }
    }
}
