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
    func point(in rect: CGRect) -> CGPoint {
        switch self {
        case .topLeading: CGPoint(x: rect.minX, y: rect.maxY)
        case .topTrailing: CGPoint(x: rect.maxX, y: rect.maxY)
        case .bottomLeading: CGPoint(x: rect.minX, y: rect.minY)
        case .bottomTrailing: CGPoint(x: rect.maxX, y: rect.minY)
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
        case .top: [.topLeading, .topTrailing]
        case .bottom: [.bottomLeading, .bottomTrailing]
        case .leading: [.topLeading, .bottomLeading]
        case .trailing: [.topTrailing, .bottomTrailing]
        }
    }

    /// The edge at the opposite end of the rectangle.
    var opposite: Edge {
        switch self {
        case .top: .bottom
        case .bottom: .top
        case .leading: .trailing
        case .trailing: .leading
        }
    }
}
