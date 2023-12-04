//
//  PopoverConfiguration.swift
//  ColorWellKit
//

import AppKit

extension ColorWell {
    /// A type that specifies the appearance and behavior of
    /// a color well's popover.
    @available(*, deprecated, message: "Use the color well's 'secondaryAction' to create a custom popover.")
    public typealias PopoverConfiguration = _PopoverConfiguration

    public struct _PopoverConfiguration {
        /// The colors that are displayed as swatches inside
        /// the popover.
        public var colors: [NSColor]

        /// The layout of the popover's content view.
        public var contentLayout: ContentLayout

        /// The size of the swatches displayed inside the
        /// popover.
        public var swatchSize: CGSize?

        /// The shape algorithm of the swatches displayed
        /// inside the popover.
        public var swatchShape: SwatchShape

        /// An effect to apply to the borders of the swatches
        /// displayed inside the popover.
        public var borderEffect: SwatchBorderEffect

        // MARK: Initializers

        /// Creates a configuration using an array of colors.
        ///
        /// - Parameters:
        ///   - colors: An array of colors to display as swatches inside the popover.
        ///   - contentLayout: The layout of the popover's content view.
        ///   - swatchSize: The size of the swatches displayed inside the popover.
        ///   - swatchShape: A shape algorithm for the swatches displayed inside the
        ///     popover.
        ///   - borderEffect: An effect to apply to the borders of the swatches
        ///     displayed inside the popover.
        public init(
            colors: [NSColor],
            contentLayout: ContentLayout = .grid(),
            swatchSize: CGSize? = nil,
            swatchShape: SwatchShape = .rectangle,
            borderEffect: SwatchBorderEffect = .default
        ) {
            self.colors = colors
            self.contentLayout = contentLayout
            self.swatchSize = swatchSize
            self.swatchShape = swatchShape
            self.borderEffect = borderEffect
        }

        /// Creates a configuration using a color list.
        ///
        /// - Parameters:
        ///   - colorList: A color list that contains the colors to display as
        ///     swatches inside the popover.
        ///   - contentLayout: The layout of the popover's content view.
        ///   - swatchSize: The size of the swatches displayed inside the popover.
        ///   - swatchShape: A shape algorithm for the swatches displayed inside the
        ///     popover.
        ///   - borderEffect: An effect to apply to the borders of the swatches
        ///     displayed inside the popover.
        public init(
            colorList: NSColorList,
            contentLayout: ContentLayout = .grid(),
            swatchSize: NSSize? = nil,
            swatchShape: SwatchShape = .rectangle,
            borderEffect: SwatchBorderEffect = .default
        ) {
            self.init(
                colors: colorList.allKeys.compactMap(colorList.color(withKey:)),
                contentLayout: contentLayout,
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
            contentLayout: ContentLayout = .grid(),
            swatchSize: NSSize? = nil,
            swatchShape: SwatchShape = .rectangle,
            borderEffect: SwatchBorderEffect = .default
        ) -> Self {
            guard
                let path = bundle.path(forResource: name, ofType: "clr"),
                let colorList = NSColorList(name: name, fromFile: path)
            else {
                preconditionFailure("Failed to load color list resource.")
            }
            return Self(
                colorList: colorList,
                contentLayout: contentLayout,
                swatchSize: swatchSize,
                swatchShape: swatchShape,
                borderEffect: borderEffect
            )
        }

        /// The default configuration.
        ///
        /// This configuration specifies a small grid of color swatches with 6
        /// columns of colors across the color spectrum.
        public static let `default`: Self = _loadColorListResource(
            name: "DefaultColors",
            bundle: .module,
            contentLayout: .grid(columnCount: 6).padding(minLength: 7.5, maxLength: 10),
            swatchSize: NSSize(width: 37, height: 20),
            borderEffect: .dynamic
        )

        /// A configuration that specifies a grid of color swatches with 12 columns
        /// of colors across the color spectrum, and a row of common colors across
        /// the top.
        public static let standard: Self = _loadColorListResource(
            name: "StandardColors",
            bundle: .module,
            contentLayout: .grid(columnCount: 12, topRowSpacing: 4),
            swatchSize: NSSize(width: 13, height: 13)
        )

        /// A configuration that specifies a single row of color swatches consisting
        /// of some of the most common colors.
        public static let simple: Self = {
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
            return Self(
                colors: colors,
                contentLayout: .grid(columnCount: 12, horizontalSpacing: 2.5),
                swatchSize: NSSize(width: 20, height: 20),
                swatchShape: .ellipse,
                borderEffect: .default.blended(with: .invert, by: 0.25)
            )
        }()

        // MARK: Instance Methods

        func computeColumnAndRowCounts(forSwatchCount swatchCount: Int) -> (columnCount: Int, rowCount: Int) {
            let swatchCountDbl = Double(swatchCount)
            let columnCountDbl: Double = {
                switch contentLayout.kind {
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
extension ColorWell._PopoverConfiguration: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.colors == rhs.colors &&
        lhs.contentLayout == rhs.contentLayout &&
        lhs.swatchSize?.width == rhs.swatchSize?.width &&
        lhs.swatchSize?.height == rhs.swatchSize?.height &&
        lhs.swatchShape == rhs.swatchShape &&
        lhs.borderEffect == rhs.borderEffect
    }
}

// MARK: PopoverConfiguration: Hashable
extension ColorWell._PopoverConfiguration: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(colors)
        hasher.combine(contentLayout)
        hasher.combine(swatchSize?.width)
        hasher.combine(swatchSize?.height)
        hasher.combine(swatchShape)
        hasher.combine(borderEffect)
    }
}

// MARK: Deprecated
extension ColorWell._PopoverConfiguration {
    /// The layout of the popover's content view.
    @available(*, deprecated, renamed: "contentLayout")
    public var layout: Layout {
        get { contentLayout }
        set { contentLayout = newValue }
    }

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
    @available(*, deprecated, renamed: "init(colors:contentLayout:swatchSize:swatchShape:borderEffect:)")
    public init(
        colors: [NSColor],
        layout: Layout = .grid(),
        swatchSize: NSSize? = nil,
        swatchShape: SwatchShape = .rectangle,
        borderEffect: SwatchBorderEffect = .default
    ) {
        self.colors = colors
        self.contentLayout = layout
        self.swatchSize = swatchSize
        self.swatchShape = swatchShape
        self.borderEffect = borderEffect
    }

    /// Creates a configuration using a color list.
    ///
    /// - Parameters:
    ///   - colorList: A color list that contains the colors to display as
    ///     swatches inside the popover.
    ///   - layout: The layout of the popover's content view.
    ///   - swatchSize: The size of the swatches displayed inside the popover.
    ///   - swatchShape: A shape algorithm for the swatches displayed inside the
    ///     popover.
    ///   - borderEffect: An effect to apply to the borders of the swatches
    ///     displayed inside the popover.
    @available(*, deprecated, renamed: "init(colorList:contentLayout:swatchSize:swatchShape:borderEffect:)")
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
}
