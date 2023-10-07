//
//  ColorInfo.swift
//  ColorWellKit
//

import AppKit

/// Container for color type and component information.
struct ColorInfo {
    /// Color type information.
    private enum ColorType {
        case componentBased(components: ColorComponents)
        case pattern(image: NSImage)
        case catalog(name: String)
        case unknown(color: NSColor)
        case deviceN
        case indexed
        case lab
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
                cwk_log(
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

    /// The name of the color type associated with this instance.
    var typeName: String {
        switch type {
        case .componentBased(let components):
            switch components {
            case .rgb:
                return "rgb"
            case .cmyk:
                return "cmyk"
            case .grayscale:
                return "grayscale"
            case .other:
                return "component-based color"
            case .invalid:
                return "invalid"
            }
        case .pattern:
            return "pattern image"
        case .catalog:
            return "catalog color"
        case .unknown:
            return "unknown color space"
        case .deviceN:
            return "deviceN"
        case .indexed:
            return "indexed"
        case .lab:
            return "L*a*b*"
        }
    }

    /// The raw components extracted from this instance.
    var extractedComponents: [Any] {
        switch type {
        case .componentBased(let components):
            switch components {
            case .rgb(let red, let green, let blue, let alpha):
                return [red, green, blue, alpha]
            case .cmyk(let cyan, let magenta, let yellow, let black, let alpha):
                return [cyan, magenta, yellow, black, alpha]
            case .grayscale(let white, let alpha):
                return [white, alpha]
            case .other(let components):
                return components
            case .invalid:
                return []
            }
        case .pattern(let image):
            return [image]
        case .catalog(let name):
            return [name]
        case .unknown(let color):
            return [String(describing: color)]
        default:
            return []
        }
    }

    /// String representations of the components extracted from this instance.
    var extractedComponentStrings: [String] {
        extractedComponents.compactMap { component in
            if let component = component as? NSNumber {
                return Self.formatter.string(from: component)
            }
            return String(describing: component)
        }
    }

    /// Creates an instance from the specified color.
    init(color: NSColor) {
        switch color.type {
        case .componentBased:
            self.type = .componentBased(components: ColorComponents(color: color))
        case .pattern:
            self.type = .pattern(image: color.patternImage)
        case .catalog:
            self.type = .catalog(name: color.localizedColorNameComponent)
        @unknown default:
            self.type = .unknown(color: color)
        }
    }
}

// MARK: ColorInfo: CustomStringConvertible
extension ColorInfo: CustomStringConvertible {
    var description: String {
        let strings = CollectionOfOne(typeName) + extractedComponentStrings
        return strings.joined(separator: " ")
    }
}
