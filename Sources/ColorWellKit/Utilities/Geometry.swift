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
