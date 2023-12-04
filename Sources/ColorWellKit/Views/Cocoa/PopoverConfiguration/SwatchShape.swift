//
//  SwatchShape.swift
//  ColorWellKit
//

import CoreGraphics

extension ColorWell._PopoverConfiguration {
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
        func swatchPath(forRect rect: CGRect) -> CGPath {
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
        func selectionPath(forRect rect: CGRect) -> CGPath {
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
extension ColorWell._PopoverConfiguration.SwatchShape: Equatable { }

// MARK: SwatchShape: Hashable
extension ColorWell._PopoverConfiguration.SwatchShape: Hashable { }
