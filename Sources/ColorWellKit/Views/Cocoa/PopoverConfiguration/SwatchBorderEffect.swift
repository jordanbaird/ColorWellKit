//
//  SwatchBorderEffect.swift
//  ColorWellKit
//

import AppKit

extension ColorWell._PopoverConfiguration {
    /// A type that applies an effect to the border color of a swatch.
    public struct SwatchBorderEffect {

        // MARK: Types

        // swiftlint:disable:next nesting
        private struct Block: IdentifiableBlock {
            let identifier: BlockIdentifier
            let body: (NSColor) -> NSColor
        }

        // MARK: Properties

        private let block: Block

        // MARK: Initializers

        /// Creates a border color effect with the given closure.
        init(block: @escaping (NSColor) -> NSColor) {
            self.block = Block(body: block)
        }

        // MARK: Constructors

        /// The default border effect.
        ///
        /// This effect lightens the border of all swatches. The intensity of the
        /// effect varies based on the brightness of the swatch, with darker swatches
        /// resulting in a more intense effect.
        public static var `default`: SwatchBorderEffect {
            SwatchBorderEffect { color in
                let intensity = color.averageBrightness / 2
                return NSColor(white: 0.75, alpha: (1 - intensity) / 3)
            }
        }

        /// A border effect that applies a black border with an alpha component of
        /// `0.5` to all swatches.
        public static var darken: SwatchBorderEffect {
            SwatchBorderEffect { _ in
                NSColor(white: 0, alpha: 0.5)
            }
        }

        /// A border effect that applies a white border with an alpha component of
        /// `0.5` to all swatches.
        public static var lighten: SwatchBorderEffect {
            SwatchBorderEffect { _ in
                NSColor(white: 1, alpha: 0.5)
            }
        }

        /// A border effect that subtly darkens the border of light colored swatches and
        /// lightens the border of dark colored swatches.
        public static var dynamic: SwatchBorderEffect {
            SwatchBorderEffect { color in
                NSColor(white: (1 - color.averageBrightness) / 4, alpha: 1 / 6)
            }
        }

        /// A border effect that inverts the color of a swatch's border.
        ///
        /// For example, an orange colored swatch will render its border with a light
        /// blue color when this effect is applied.
        public static var invert: SwatchBorderEffect {
            SwatchBorderEffect { color in
                guard let color = color.usingColorSpace(.genericRGB) else {
                    return color
                }
                return NSColor(
                    calibratedRed: abs(1 - color.redComponent),
                    green: abs(1 - color.greenComponent),
                    blue: abs(1 - color.blueComponent),
                    alpha: color.alphaComponent
                )
            }
        }

        /// Returns a border effect that uses the given color to draw swatch borders,
        /// regardless of the swatch's fill color.
        ///
        /// - Parameter color: A color for the effect to use to draw swatch borders.
        ///
        /// - Returns: A border effect that uses a color to draw swatch borders.
        public static func color(_ color: NSColor) -> SwatchBorderEffect {
            SwatchBorderEffect { _ in color }
        }

        /// Returns a border effect that transforms the fill color of a swatch into
        /// a border color using a closure.
        ///
        /// - Parameter body: A closure that takes the fill color of a swatch and
        ///   returns a color to use as its border.
        ///
        /// - Returns: A transforming border effect.
        public static func transform(_ body: @escaping (NSColor) -> NSColor) -> SwatchBorderEffect {
            SwatchBorderEffect(block: body)
        }

        // MARK: Instance Methods

        func borderColor(from color: NSColor) -> NSColor {
            block(color)
        }

        /// Returns a border effect that applies the given effect to the result
        /// of this effect.
        ///
        /// - Parameter effect: The effect to apply to this effect's result.
        ///
        /// - Returns: A border effect that applies the given effect to the
        ///   this effect.
        public func applying(_ effect: SwatchBorderEffect) -> SwatchBorderEffect {
            SwatchBorderEffect { color in
                effect.borderColor(from: borderColor(from: color))
            }
        }

        /// Returns a border effect that blends the current border effect with
        /// another border effect.
        ///
        /// - Parameters:
        ///   - other: Another border effect with which to blend this effect.
        ///   - fraction: The amount of the other effect to blend into this effect.
        ///
        /// - Returns: A border effect that blends the results of the two effects.
        public func blended(with other: SwatchBorderEffect, by fraction: CGFloat) -> SwatchBorderEffect {
            SwatchBorderEffect { color in
                borderColor(from: color)
                    .blending(
                        fraction: fraction,
                        of: other.borderColor(from: color)
                    )
            }
        }

        /// Returns a border effect that applies the given opacity value to the
        /// current border effect.
        ///
        /// - Parameter opacity: The opacity value to apply to this effect.
        ///
        /// - Returns: A border effect that applies the given opacity value to
        ///   this effect.
        public func withOpacity(_ opacity: CGFloat) -> SwatchBorderEffect {
            SwatchBorderEffect { color in
                borderColor(from: color)
                    .withAlphaComponent(opacity)
            }
        }
    }
}

// MARK: SwatchBorderEffect: Equatable
extension ColorWell._PopoverConfiguration.SwatchBorderEffect: Equatable { }

// MARK: SwatchBorderEffect: Hashable
extension ColorWell._PopoverConfiguration.SwatchBorderEffect: Hashable { }
