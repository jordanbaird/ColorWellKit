//
//  Geometry.swift
//  ColorWellKit
//

import CoreGraphics

// MARK: - Corner

/// A type that represents a corner of a rectangle.
enum Corner {
    /// The top leading corner of a rectangle.
    case topLeading

    /// The top trailing corner of a rectangle.
    case topTrailing

    /// The bottom leading corner of a rectangle.
    case bottomLeading

    /// The bottom trailing corner of a rectangle.
    case bottomTrailing

    /// All corners, in the order that they appear in a clockwise
    /// traversal around a rectangle.
    static let clockwiseOrder: [Corner] = [
        .topLeading,
        .topTrailing,
        .bottomTrailing,
        .bottomLeading,
    ]

    /// Returns the point in the given rectangle that corresponds
    /// to this corner.
    func point(inRect rect: CGRect) -> CGPoint {
        switch self {
        case .topLeading:
            return CGPoint(x: rect.minX, y: rect.maxY)
        case .topTrailing:
            return CGPoint(x: rect.maxX, y: rect.maxY)
        case .bottomLeading:
            return CGPoint(x: rect.minX, y: rect.minY)
        case .bottomTrailing:
            return CGPoint(x: rect.maxX, y: rect.minY)
        }
    }
}

// MARK: - Edge

/// A type that represents an edge of a rectangle.
enum Edge {
    /// The top edge of a rectangle.
    case top

    /// The bottom edge of a rectangle.
    case bottom

    /// The leading edge of a rectangle.
    case leading

    /// The trailing edge of a rectangle.
    case trailing

    /// The corners that, when connected by a path, make up this edge.
    var corners: [Corner] {
        switch self {
        case .top:
            return [.topLeading, .topTrailing]
        case .bottom:
            return [.bottomLeading, .bottomTrailing]
        case .leading:
            return [.topLeading, .bottomLeading]
        case .trailing:
            return [.topTrailing, .bottomTrailing]
        }
    }

    /// The edge at the opposite end of the rectangle.
    var opposite: Edge {
        switch self {
        case .top:
            return .bottom
        case .bottom:
            return .top
        case .leading:
            return .trailing
        case .trailing:
            return .leading
        }
    }
}

// MARK: - PaddingRanges

/// A type that contains the minimum and maximum padding amounts
/// to apply to the edges of a rectangle.
struct PaddingRanges: Hashable {
    /// The padding range for the leading edge of the rectangle.
    var leading: PaddingRange
    /// The padding range for the trailing edge of the rectangle.
    var trailing: PaddingRange
    /// The padding range for the top edge of the rectangle.
    var top: PaddingRange
    /// The padding range for the bottom edge of the rectangle.
    var bottom: PaddingRange

    /// A padding ranges instance whose ranges are all the empty
    /// padding range.
    static let empty = PaddingRanges(
        leading: .empty,
        trailing: .empty,
        top: .empty,
        bottom: .empty
    )

    /// Returns a new instance that is the result of adding the
    /// ranges of another instance to the ranges of this instance.
    func adding(_ other: PaddingRanges) -> PaddingRanges {
        PaddingRanges(
            leading: leading.adding(other.leading),
            trailing: trailing.adding(other.trailing),
            top: top.adding(other.top),
            bottom: bottom.adding(other.bottom)
        )
    }
}

extension PaddingRanges {
    /// A type that contains a minimum and maximum amount of padding
    /// to apply an edge of a rectangle.
    struct PaddingRange: Hashable {
        /// The minimum padding value of the range.
        var min: CGFloat?
        /// The maximum padding value of the range.
        var max: CGFloat?

        /// The empty padding range.
        static let empty = PaddingRange(min: nil, max: nil)

        /// Returns a padding range with the given minimum and maximum
        /// padding values.
        static func range(min: CGFloat? = nil, max: CGFloat? = nil) -> PaddingRange {
            PaddingRange(min: min, max: max)
        }

        /// Returns a new padding range that is the result of adding the
        /// values of another padding range to the values of this range.
        func adding(_ other: PaddingRange) -> PaddingRange {
            func add(_ value1: CGFloat?, _ value2: CGFloat?) -> CGFloat? {
                if value1 == nil && value2 == nil {
                    return nil
                }
                return (value1 ?? 0) + (value2 ?? 0)
            }

            return PaddingRange(
                min: add(min, other.min),
                max: add(max, other.max)
            )
        }
    }
}
