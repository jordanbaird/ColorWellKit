//
//  PopoverConfiguration.swift
//  ColorWellKit
//

import AppKit

extension ColorWell {
    /// A type that specifies the appearance of the user-selectable swatches
    /// in a color well's popover.
    public struct PopoverConfiguration {

        // MARK: Properties

        /// The colors that are displayed as swatches inside the popover.
        public var colors: [NSColor]

        /// The layout of the popover's content view.
        public var layout: Layout

        /// The size of the swatches displayed inside the popover.
        public var swatchSize: NSSize?

        /// The shape algorithm of the swatches displayed inside the popover.
        public var swatchShape: SwatchShape

        /// An effect to apply to the borders of the swatches displayed inside
        /// the popover.
        public var borderEffect: SwatchBorderEffect

        // MARK: Initializers

        /// Creates a configuration using an array of colors.
        ///
        /// - Parameters:
        ///   - colors: An array of colors to display as swatches inside the popover.
        ///   - layout: The layout of the popover's content view.
        ///   - swatchSize: The size of the swatches displayed inside the popover.
        ///   - swatchShape: A shape algorithm for the swatches displayed inside the
        ///     popover.
        ///   - borderEffect: An effect to apply to the borders of the swatches
        ///     displayed inside the popover.
        public init(
            colors: [NSColor],
            layout: Layout = .grid(),
            swatchSize: NSSize? = nil,
            swatchShape: SwatchShape = .rectangle,
            borderEffect: SwatchBorderEffect = .default
        ) {
            self.colors = colors
            self.layout = layout
            self.swatchSize = swatchSize
            self.swatchShape = swatchShape
            self.borderEffect = borderEffect
        }

        /// Creates a configuration using a color list.
        ///
        /// - Parameters:
        ///   - colorList: A color list that contains the colors to display as
        ///     swatches inside the popover.
        ///   - layout: A configuration for the layout of the popover's grid view.
        ///   - swatchSize: The size of the swatches displayed inside the popover.
        ///   - swatchShape: A shape algorithm for the swatches displayed inside the
        ///     popover.
        ///   - borderEffect: An effect to apply to the borders of the swatches
        ///     displayed inside the popover.
        public init(
            colorList: NSColorList,
            layout: Layout = .grid(),
            swatchSize: NSSize? = nil,
            swatchShape: SwatchShape = .rectangle,
            borderEffect: SwatchBorderEffect = .default
        ) {
            self.init(
                colors: colorList.allKeys.compactMap(colorList.color(withKey:)),
                layout: layout,
                swatchSize: swatchSize,
                swatchShape: swatchShape,
                borderEffect: borderEffect
            )
        }

        // MARK: Constructors

        /// Loads a color list resource from a file in the package's bundle.
        ///
        /// - Important: If you use this constructor, be absolutely certain that a
        ///   valid `clr` file exists in the package's `Resources` folder, and that
        ///   it has been explicitly declared as a resource in `Package.swift`.
        private static func _loadColorListResource(
            name: String,
            bundle: Bundle,
            layout: Layout = .grid(),
            swatchSize: NSSize? = nil,
            swatchShape: SwatchShape = .rectangle,
            borderEffect: SwatchBorderEffect = .default
        ) -> PopoverConfiguration {
            guard
                let path = bundle.path(forResource: name, ofType: "clr"),
                let colorList = NSColorList(name: name, fromFile: path)
            else {
                preconditionFailure("Failed to load color list resource.")
            }
            return PopoverConfiguration(
                colorList: colorList,
                layout: layout,
                swatchSize: swatchSize,
                swatchShape: swatchShape,
                borderEffect: borderEffect
            )
        }

        /// The default configuration.
        ///
        /// This configuration specifies a small grid of color swatches with 6
        /// columns of colors across the color spectrum.
        public static let `default`: PopoverConfiguration = _loadColorListResource(
            name: "DefaultColors",
            bundle: .module,
            layout: .grid(columnCount: 6).padding(minLength: 7.5, maxLength: 10),
            swatchSize: NSSize(width: 37, height: 20),
            borderEffect: .dynamic
        )

        /// A configuration that specifies a grid of color swatches with 12 columns
        /// of colors across the color spectrum, and a row of common colors across
        /// the top.
        public static let standard: PopoverConfiguration = _loadColorListResource(
            name: "StandardColors",
            bundle: .module,
            layout: .grid(columnCount: 12, topRowSpacing: 4),
            swatchSize: NSSize(width: 13, height: 13)
        )

        /// A configuration that specifies a single row of color swatches consisting
        /// of some of the most common colors.
        public static let simple: PopoverConfiguration = {
            let hexStrings = [
                "FF0000", // red
                "FF8000", // orange
                "FFFF00", // yellow
                "00FF00", // green
                "00FFFF", // cyan
                "0000FF", // blue
                "FF00FF", // magenta
                "800080", // purple
                "964B00", // brown
                "FFFFFF", // white
                "808080", // gray
                "000000", // black
            ]
            let colors = hexStrings.compactMap { string in
                NSColor(hexString: string)
            }
            return PopoverConfiguration(
                colors: colors,
                layout: .grid(columnCount: 12, horizontalSpacing: 2.5),
                swatchSize: NSSize(width: 20, height: 20),
                swatchShape: .ellipse,
                borderEffect: .default.blended(with: .invert, by: 0.25)
            )
        }()

        // MARK: Instance Methods

        func computeColumnAndRowCounts(forSwatchCount swatchCount: Int) -> (columnCount: Int, rowCount: Int) {
            let swatchCountDbl = Double(swatchCount)
            let columnCountDbl: Double = {
                switch layout.kind {
                case let .grid(columnCount, _, _, _):
                    if let columnCount {
                        // we have an explicit column count
                        return Double(columnCount)
                    }

                    // compute the column count based on the smallest number that
                    // evenly divides into the total number of swatches (skipping
                    // 0 and 1, as they produce false positives)
                    for n in 2...swatchCount {
                        let divisor = Double(n)
                        if swatchCountDbl.remainder(dividingBy: divisor) == 0 {
                            return swatchCountDbl / divisor
                        }
                    }

                    // no even divisions; get the square root of the swatch count
                    // and round up to get as close to an equal number of swatches
                    // per row as possible; don't allow column counts lower than 4
                    return max(4, sqrt(swatchCountDbl).rounded(.up))
                }
            }()

            let rowCount = Int((swatchCountDbl / columnCountDbl).rounded(.up))
            let columnCount = Int(columnCountDbl)
            return (columnCount, rowCount)
        }

        func computeColumnCount() -> Int {
            computeColumnAndRowCounts(forSwatchCount: colors.count).columnCount
        }

        func computeRowCount() -> Int {
            computeColumnAndRowCounts(forSwatchCount: colors.count).rowCount
        }

        func computeSwatchSize() -> NSSize {
            if let swatchSize {
                return swatchSize
            }
            let rowCount = computeRowCount()
            if rowCount < 6 {
                return NSSize(width: 30, height: 30)
            }
            if rowCount < 10 {
                return NSSize(width: 20, height: 20)
            }
            return NSSize(width: 15, height: 15)
        }
    }
}

// MARK: PopoverConfiguration: Equatable
extension ColorWell.PopoverConfiguration: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.colors == rhs.colors &&
        lhs.layout == rhs.layout &&
        lhs.swatchSize?.width == rhs.swatchSize?.width &&
        lhs.swatchSize?.height == rhs.swatchSize?.height &&
        lhs.swatchShape == rhs.swatchShape &&
        lhs.borderEffect == rhs.borderEffect
    }
}

// MARK: PopoverConfiguration: Hashable
extension ColorWell.PopoverConfiguration: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(colors)
        hasher.combine(layout)
        hasher.combine(swatchSize?.width)
        hasher.combine(swatchSize?.height)
        hasher.combine(swatchShape)
        hasher.combine(borderEffect)
    }
}

// MARK: Layout

extension ColorWell.PopoverConfiguration {
    /// A type that configures the layout of a popover's grid view.
    public struct Layout {

        // MARK: Types

        // swiftlint:disable:next nesting
        enum Kind: Hashable {
            case grid(
                columnCount: Int?,
                horizontalSpacing: CGFloat?,
                verticalSpacing: CGFloat?,
                topRowSpacing: CGFloat?
            )
        }

        let kind: Kind

        let padding: PaddingRanges

        // MARK: Constructors

        /// Creates a grid layout with the given number of columns, horizontal and
        /// vertical spacing, and top row spacing.
        ///
        /// - Parameters:
        ///   - columnCount: The number of columns to allow in the grid view.
        ///   - horizontalSpacing: The horizontal distance between cells in the
        ///     grid view.
        ///   - verticalSpacing: The vertical distance between cells in the
        ///     grid view.
        ///   - topRowSpacing: The distance between the top row and the remaining
        ///     content in the grid view.
        public static func grid(
            columnCount: Int? = nil,
            horizontalSpacing: CGFloat? = nil,
            verticalSpacing: CGFloat? = nil,
            topRowSpacing: CGFloat? = nil
        ) -> Layout {
            Layout(
                kind: .grid(
                    columnCount: columnCount,
                    horizontalSpacing: horizontalSpacing,
                    verticalSpacing: verticalSpacing,
                    topRowSpacing: topRowSpacing
                ),
                padding: .empty
            )
        }

        // MARK: Instance Methods

        func padding(_ padding: PaddingRanges) -> Layout {
            Layout(kind: kind, padding: self.padding.adding(padding))
        }

        /// Returns a layout with the given minimum and maximum padding values
        /// added to the edges of the layout.
        ///
        /// - Parameters:
        ///   - minLeading: The minimum amount of padding in points to add to the
        ///     leading edge of the layout.
        ///   - maxLeading: The maximum amount of padding in points to add to the
        ///     leading edge of the layout.
        ///   - minTrailing: The minimum amount of padding in points to add to
        ///     the trailing edge of the layout.
        ///   - maxTrailing: The maximum amount of padding in points to add to
        ///     the trailing edge of the layout.
        ///   - minTop: The minimum amount of padding in points to add to the
        ///     top edge of the layout.
        ///   - maxTop: The maximum amount of padding in points to add to the
        ///     top edge of the layout.
        ///   - minBottom: The minimum amount of padding in points to add to the
        ///     bottom edge of the layout.
        ///   - maxBottom: The maximum amount of padding in points to add to the
        ///     bottom edge of the layout.
        public func padding(
            minLeading: CGFloat? = nil,
            maxLeading: CGFloat? = nil,
            minTrailing: CGFloat? = nil,
            maxTrailing: CGFloat? = nil,
            minTop: CGFloat? = nil,
            maxTop: CGFloat? = nil,
            minBottom: CGFloat? = nil,
            maxBottom: CGFloat? = nil
        ) -> Layout {
            padding(
                PaddingRanges(
                    leading: .range(min: minLeading, max: maxLeading),
                    trailing: .range(min: minTrailing, max: maxTrailing),
                    top: .range(min: minTop, max: maxTop),
                    bottom: .range(min: minBottom, max: maxBottom)
                )
            )
        }

        /// Returns a layout with the given minimum and maximum padding values
        /// added to the edges of the layout.
        ///
        /// - Parameters:
        ///   - leading: The amount of padding in points to add to the leading
        ///     edge of the layout.
        ///   - trailing: The amount of padding in points to add to the trailing
        ///     edge of the layout.
        ///   - top: The amount of padding in points to add to the top edge of
        ///     the layout.
        ///   - bottom: The amount of padding in points to add to the bottom edge
        ///     of the layout.
        public func padding(
            leading: CGFloat? = nil,
            trailing: CGFloat? = nil,
            top: CGFloat? = nil,
            bottom: CGFloat? = nil
        ) -> Layout {
            padding(
                minLeading: leading,
                maxLeading: leading,
                minTrailing: trailing,
                maxTrailing: trailing,
                minTop: top,
                maxTop: top,
                minBottom: bottom,
                maxBottom: bottom
            )
        }

        /// Returns a layout with the given minimum and maximum padding values
        /// added to the edges of the layout.
        ///
        /// - Parameters:
        ///   - minLength: The minimum amount of padding in points to add to each
        ///     edge of the layout.
        ///   - maxLength: The maximum amount of padding in points to add to each
        ///     edge of the layout.
        public func padding(
            minLength: CGFloat? = nil,
            maxLength: CGFloat? = nil
        ) -> Layout {
            padding(
                minLeading: minLength,
                maxLeading: maxLength,
                minTrailing: minLength,
                maxTrailing: maxLength,
                minTop: minLength,
                maxTop: maxLength,
                minBottom: minLength,
                maxBottom: maxLength
            )
        }

        /// Returns a layout with a fixed padding value added to the edges of
        /// the layout.
        ///
        /// - Parameter length: The amount of padding in points to add to each
        ///   edge of the layout.
        public func padding(_ length: CGFloat) -> Layout {
            padding(
                minLength: length,
                maxLength: length
            )
        }
    }
}

// MARK: Layout: Equatable
extension ColorWell.PopoverConfiguration.Layout: Equatable { }

// MARK: Layout: Hashable
extension ColorWell.PopoverConfiguration.Layout: Hashable { }

// MARK: SwatchShape

extension ColorWell.PopoverConfiguration {
    /// An algorithm that specifies the shape for swatches displayed inside
    /// a color well's popover.
    public struct SwatchShape {

        // MARK: Types

        // swiftlint:disable:next nesting
        private struct Block: IdentifiableBlock {
            let identifier: BlockIdentifier
            let body: (CGRect) -> CGPath
        }

        // swiftlint:disable:next nesting
        private enum Kind: Hashable {
            case rectangle
            case ellipse
            case roundedRectangle(xRadius: CGFloat, yRadius: CGFloat)
            case custom(Block)
        }

        // MARK: Properties

        private let kind: Kind

        // MARK: Constructors

        /// A shape algorithm that specifies that swatches are drawn as
        /// rectangles.
        public static var rectangle: SwatchShape {
            SwatchShape(kind: .rectangle)
        }

        /// A shape algorithm that specifies that swatches are drawn as
        /// ellipses.
        public static var ellipse: SwatchShape {
            SwatchShape(kind: .ellipse)
        }

        /// A shape algorithm that specifies that swatches are drawn as
        /// rounded rectangles.
        ///
        /// - Parameter cornerSize: The size of the rounded corners of
        ///   the rectangle.
        public static func roundedRectangle(cornerSize: CGSize) -> SwatchShape {
            SwatchShape(kind: .roundedRectangle(xRadius: cornerSize.width, yRadius: cornerSize.height))
        }

        /// A shape algorithm that specifies that swatches are drawn as
        /// rounded rectangles.
        ///
        /// - Parameter cornerRadius: The radius of the rounded corners of
        ///   the rectangle.
        public static func roundedRectangle(cornerRadius: CGFloat) -> SwatchShape {
            roundedRectangle(cornerSize: CGSize(width: cornerRadius, height: cornerRadius))
        }

        /// A shape algorithm that specifies that swatches are drawn using
        /// a custom path returned from a closure.
        ///
        /// - Parameter body: A closure that takes the portion of a swatch
        ///   that has been marked for drawing and returns a path that defines
        ///   the shape of the swatch.
        public static func custom(_ body: @escaping (CGRect) -> CGPath) -> SwatchShape {
            SwatchShape(kind: .custom(Block(body: body)))
        }

        // MARK: Instance Methods

        /// Returns the path for a swatch with this shape.
        func swatchPath(forRect rect: NSRect) -> CGPath {
            switch kind {
            case .rectangle:
                return CGPath(rect: rect, transform: nil)
            case .ellipse:
                return CGPath(ellipseIn: rect, transform: nil)
            case .roundedRectangle(let xRadius, let yRadius):
                return CGPath(
                    roundedRect: rect,
                    cornerWidth: xRadius,
                    cornerHeight: yRadius,
                    transform: nil
                )
            case .custom(let block):
                return block(rect)
            }
        }

        /// Returns the path for the selection indicator of a swatch with this shape.
        func selectionPath(forRect rect: NSRect) -> CGPath {
            let path: Path
            if case .rectangle = kind {
                let minDimension = min(rect.width, rect.height)
                let radius = (minDimension / 10).clamped(to: 1...5)
                let cgPath = CGPath(
                    roundedRect: rect,
                    cornerWidth: radius,
                    cornerHeight: radius,
                    transform: nil
                )
                path = Path(cgPath: cgPath)
            } else {
                path = Path(cgPath: swatchPath(forRect: rect))
            }
            return path.cgPath()
        }
    }
}

// MARK: SwatchShape: Equatable
extension ColorWell.PopoverConfiguration.SwatchShape: Equatable { }

// MARK: SwatchShape: Hashable
extension ColorWell.PopoverConfiguration.SwatchShape: Hashable { }

// MARK: SwatchBorderEffect

extension ColorWell.PopoverConfiguration {
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
extension ColorWell.PopoverConfiguration.SwatchBorderEffect: Equatable { }

// MARK: SwatchBorderEffect: Hashable
extension ColorWell.PopoverConfiguration.SwatchBorderEffect: Hashable { }
