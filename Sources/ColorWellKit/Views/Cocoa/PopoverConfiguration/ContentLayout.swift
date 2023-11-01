//
//  ContentLayout.swift
//  ColorWellKit
//

import CoreGraphics

extension ColorWell.PopoverConfiguration {
    /// A type that configures the layout of a popover's content view.
    public struct ContentLayout {
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

        /// Creates a content layout for a grid with the given number of
        /// columns and spacing.
        ///
        /// - Parameters:
        ///   - columnCount: The number of columns to allow in the grid.
        ///   - horizontalSpacing: The horizontal distance between cells
        ///     in the grid.
        ///   - verticalSpacing: The vertical distance between cells in
        ///     the grid.
        ///   - topRowSpacing: The distance between the top row and the
        ///     remaining content in the grid.
        public static func grid(
            columnCount: Int? = nil,
            horizontalSpacing: CGFloat? = nil,
            verticalSpacing: CGFloat? = nil,
            topRowSpacing: CGFloat? = nil
        ) -> ContentLayout {
            ContentLayout(
                kind: .grid(
                    columnCount: columnCount,
                    horizontalSpacing: horizontalSpacing,
                    verticalSpacing: verticalSpacing,
                    topRowSpacing: topRowSpacing
                ),
                padding: .empty
            )
        }

        func padding(_ padding: PaddingRanges) -> ContentLayout {
            ContentLayout(kind: kind, padding: self.padding.adding(padding))
        }

        /// Returns a content layout with the given minimum and maximum
        /// padding values added to its edges.
        ///
        /// - Parameters:
        ///   - minLeading: The minimum amount of padding in points to
        ///     add to the leading edge.
        ///   - maxLeading: The maximum amount of padding in points to
        ///     add to the leading edge.
        ///   - minTrailing: The minimum amount of padding in points to
        ///     add to the trailing edge.
        ///   - maxTrailing: The maximum amount of padding in points to
        ///     add to the trailing edge.
        ///   - minTop: The minimum amount of padding in points to add
        ///     to the top edge.
        ///   - maxTop: The maximum amount of padding in points to add
        ///     to the top edge.
        ///   - minBottom: The minimum amount of padding in points to
        ///     add to the bottom edge.
        ///   - maxBottom: The maximum amount of padding in points to
        ///     add to the bottom edge.
        public func padding(
            minLeading: CGFloat? = nil,
            maxLeading: CGFloat? = nil,
            minTrailing: CGFloat? = nil,
            maxTrailing: CGFloat? = nil,
            minTop: CGFloat? = nil,
            maxTop: CGFloat? = nil,
            minBottom: CGFloat? = nil,
            maxBottom: CGFloat? = nil
        ) -> ContentLayout {
            padding(
                PaddingRanges(
                    leading: .range(min: minLeading, max: maxLeading),
                    trailing: .range(min: minTrailing, max: maxTrailing),
                    top: .range(min: minTop, max: maxTop),
                    bottom: .range(min: minBottom, max: maxBottom)
                )
            )
        }

        /// Returns a content layout with the given minimum and maximum
        /// padding values added to its edges.
        ///
        /// - Parameters:
        ///   - leading: The amount of padding in points to add to the
        ///     leading edge.
        ///   - trailing: The amount of padding in points to add to the
        ///     trailing edge.
        ///   - top: The amount of padding in points to add to the top
        ///     edge.
        ///   - bottom: The amount of padding in points to add to the
        ///     bottom edge.
        public func padding(
            leading: CGFloat? = nil,
            trailing: CGFloat? = nil,
            top: CGFloat? = nil,
            bottom: CGFloat? = nil
        ) -> ContentLayout {
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

        /// Returns a content layout with the given minimum and maximum
        /// padding values added to its edges.
        ///
        /// - Parameters:
        ///   - minLength: The minimum amount of padding in points to add
        ///     to each edge.
        ///   - maxLength: The maximum amount of padding in points to add
        ///     to each edge.
        public func padding(
            minLength: CGFloat? = nil,
            maxLength: CGFloat? = nil
        ) -> ContentLayout {
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

        /// Returns a content layout with a fixed padding value added
        /// to its edges.
        ///
        /// - Parameter length: The amount of padding in points to add
        ///   to each edge.
        public func padding(_ length: CGFloat) -> ContentLayout {
            padding(
                minLength: length,
                maxLength: length
            )
        }
    }
}

// MARK: ContentLayout: Equatable
extension ColorWell.PopoverConfiguration.ContentLayout: Equatable { }

// MARK: ContentLayout: Hashable
extension ColorWell.PopoverConfiguration.ContentLayout: Hashable { }

// MARK: Deprecated
extension ColorWell.PopoverConfiguration {
    /// A type that configures the layout of a popover's content view.
    @available(*, deprecated, renamed: "ContentLayout")
    public typealias Layout = ContentLayout
}
