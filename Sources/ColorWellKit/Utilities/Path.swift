//
//  Path.swift
//  ColorWellKit
//

import AppKit

/// A generic interface over a graphics path.
struct Path {
    /// An element in a path.
    enum Element {
        case move(to: CGPoint)
        case line(to: CGPoint)
        case quadCurve(to: CGPoint, control: CGPoint)
        case curve(to: CGPoint, control1: CGPoint, control2: CGPoint)
        case arc(through: CGPoint, to: CGPoint, radius: CGFloat)
        case compound(elements: [Element])
        case close

        static func arc(around corner: Corner, ofRect rect: CGRect, radius: CGFloat) -> Element {
            let mid = corner.point(in: rect)

            let start: CGPoint
            let end: CGPoint

            switch corner {
            case .topLeading:
                start = mid.applying(CGAffineTransform(translationX: 0, y: -radius))
                end = mid.applying(CGAffineTransform(translationX: radius, y: 0))
            case .topTrailing:
                start = mid.applying(CGAffineTransform(translationX: -radius, y: 0))
                end = mid.applying(CGAffineTransform(translationX: 0, y: -radius))
            case .bottomTrailing:
                start = mid.applying(CGAffineTransform(translationX: 0, y: radius))
                end = mid.applying(CGAffineTransform(translationX: -radius, y: 0))
            case .bottomLeading:
                start = mid.applying(CGAffineTransform(translationX: radius, y: 0))
                end = mid.applying(CGAffineTransform(translationX: 0, y: radius))
            }

            return .compound(elements: [
                .line(to: start),
                .arc(through: mid, to: end, radius: radius),
            ])
        }
    }

    /// The elements that make up this path.
    private(set) var elements: [Element]

    /// Creates a path with the given elements.
    init(elements: [Element]) {
        self.elements = elements
    }

    /// Creates an empty path.
    init() {
        self.init(elements: [])
    }

    /// Creates a path from the elements of a Core Graphics path.
    init(cgPath: CGPath) {
        var elements = [Element]()
        cgPath.applyWithBlock { element in
            let points = element.pointee.points
            switch element.pointee.type {
            case .moveToPoint:
                elements.append(.move(to: points[0]))
            case .addLineToPoint:
                elements.append(.line(to: points[0]))
            case .addQuadCurveToPoint:
                elements.append(.quadCurve(to: points[1], control: points[0]))
            case .addCurveToPoint:
                elements.append(.curve(to: points[2], control1: points[0], control2: points[1]))
            case .closeSubpath:
                elements.append(.close)
            @unknown default:
                break
            }
        }
        self.init(elements: elements)
    }

    private static func cornerRadius(for controlSize: NSControl.ControlSize?) -> CGFloat {
        var radius: CGFloat = 5
        switch controlSize {
        case .large:
            radius += 0.25
        case .regular, .none:
            break // no change
        case .small:
            radius -= 1.25
        case .mini:
            radius -= 1.75
        @unknown default:
            break
        }
        return radius
    }

    static func colorWellPath(
        rect: CGRect,
        controlSize: NSControl.ControlSize?,
        flatteningEdge edge: Edge? = nil,
        shouldClose: Bool = true
    ) -> Path {
        let radius = cornerRadius(for: controlSize)
        let squaredCorners = edge?.corners ?? []
        var elements: [Element] = Corner.clockwiseOrder.map { corner in
            if squaredCorners.contains(corner) {
                return .line(to: corner.point(in: rect))
            }
            return .arc(around: corner, ofRect: rect, radius: radius)
        }
        if shouldClose {
            elements.append(.close)
        }
        return Path(elements: elements)
    }

    static func segmentPath(
        rect: CGRect,
        controlSize: NSControl.ControlSize?,
        segmentType: CWColorWellSegment.Type,
        shouldClose: Bool = true
    ) -> Path {
        // flatten the opposite edge to join up with the
        // segment on the other side
        let flatEdge = segmentType.edge?.opposite
        return colorWellPath(
            rect: rect,
            controlSize: controlSize,
            flatteningEdge: flatEdge,
            shouldClose: shouldClose
        )
    }

    static func fullColorWellPath(
        rect: CGRect,
        controlSize: NSControl.ControlSize?
    ) -> Path {
        colorWellPath(
            rect: rect,
            controlSize: controlSize,
            flatteningEdge: nil,
            shouldClose: true
        )
    }

    /// Creates and returns an equivalent `CGPath`.
    func cgPath() -> CGPath {
        func beginSubpath(in cgPath: CGMutablePath, at point: CGPoint, startPoint: inout CGPoint?) {
            cgPath.move(to: point)
            startPoint = point
        }

        func apply(element: Element, to cgPath: CGMutablePath, startPoint: inout CGPoint?) {
            switch element {
            case .move(let point):
                beginSubpath(in: cgPath, at: point, startPoint: &startPoint)
            case .line(let point):
                if cgPath.isEmpty {
                    beginSubpath(in: cgPath, at: point, startPoint: &startPoint)
                } else {
                    cgPath.addLine(to: point)
                }
            case .quadCurve(let point, let control):
                if cgPath.isEmpty {
                    beginSubpath(in: cgPath, at: point, startPoint: &startPoint)
                } else {
                    cgPath.addQuadCurve(to: point, control: control)
                }
            case .curve(let point, let control1, let control2):
                if cgPath.isEmpty {
                    beginSubpath(in: cgPath, at: point, startPoint: &startPoint)
                } else {
                    cgPath.addCurve(to: point, control1: control1, control2: control2)
                }
            case .arc(let midPoint, let endPoint, let radius):
                if cgPath.isEmpty {
                    beginSubpath(in: cgPath, at: endPoint, startPoint: &startPoint)
                } else {
                    cgPath.addArc(tangent1End: midPoint, tangent2End: endPoint, radius: radius)
                }
            case .compound(let elements):
                for element in elements {
                    apply(element: element, to: cgPath, startPoint: &startPoint)
                }
            case .close:
                cgPath.closeSubpath()
                if let start = startPoint {
                    beginSubpath(in: cgPath, at: start, startPoint: &startPoint)
                }
            }
        }

        let cgPath = CGMutablePath()
        var startPoint: CGPoint?

        for element in elements {
            apply(element: element, to: cgPath, startPoint: &startPoint)
        }

        return cgPath
    }

    /// Creates and returns an equivalent `NSBezierPath`.
    func nsBezierPath() -> NSBezierPath {
        func beginSubpath(in nsBezierPath: NSBezierPath, at point: CGPoint, startPoint: inout CGPoint?) {
            nsBezierPath.move(to: point)
            startPoint = point
        }

        func apply(element: Element, to nsBezierPath: NSBezierPath, startPoint: inout CGPoint?) {
            switch element {
            case .move(let point):
                beginSubpath(in: nsBezierPath, at: point, startPoint: &startPoint)
            case .line(let point):
                if nsBezierPath.isEmpty {
                    beginSubpath(in: nsBezierPath, at: point, startPoint: &startPoint)
                } else {
                    nsBezierPath.line(to: point)
                }
            case .quadCurve(let point, let control):
                if nsBezierPath.isEmpty {
                    beginSubpath(in: nsBezierPath, at: point, startPoint: &startPoint)
                } else {
                    nsBezierPath.curve(to: point, controlPoint1: control, controlPoint2: control)
                }
            case .curve(let point, let control1, let control2):
                if nsBezierPath.isEmpty {
                    beginSubpath(in: nsBezierPath, at: point, startPoint: &startPoint)
                } else {
                    nsBezierPath.curve(to: point, controlPoint1: control1, controlPoint2: control2)
                }
            case .arc(let midPoint, let endPoint, let radius):
                if nsBezierPath.isEmpty {
                    beginSubpath(in: nsBezierPath, at: endPoint, startPoint: &startPoint)
                } else {
                    nsBezierPath.appendArc(from: midPoint, to: endPoint, radius: radius)
                }
            case .compound(let elements):
                for element in elements {
                    apply(element: element, to: nsBezierPath, startPoint: &startPoint)
                }
            case .close:
                nsBezierPath.close()
                if let start = startPoint {
                    beginSubpath(in: nsBezierPath, at: start, startPoint: &startPoint)
                }
            }
        }

        let nsBezierPath = NSBezierPath()
        var startPoint: CGPoint?

        for element in elements {
            apply(element: element, to: nsBezierPath, startPoint: &startPoint)
        }

        return nsBezierPath
    }

    /// Fills the path with the given color using the specified winding
    /// rule, applying the given transformation matrix before performing
    /// the operation.
    func fill(
        with color: NSColor,
        windingRule: NSBezierPath.WindingRule = .nonZero,
        transform: AffineTransform = .identity
    ) {
        guard let context = NSGraphicsContext.current else {
            return
        }

        context.saveGraphicsState()
        defer {
            context.restoreGraphicsState()
        }

        color.setFill()

        let path = nsBezierPath()
        path.windingRule = windingRule
        path.transform(using: transform)
        path.fill()
    }

    /// Strokes the path with the given color, using the specified line
    /// width, line cap style, line join style, and miter limit, applying
    /// the given transformation matrix before performing the operation.
    func stroke(
        with color: NSColor,
        lineWidth: CGFloat = 1,
        lineCapStyle: NSBezierPath.LineCapStyle = .butt,
        lineJoinStyle: NSBezierPath.LineJoinStyle = .miter,
        miterLimit: CGFloat = 10,
        transform: AffineTransform = .identity
    ) {
        guard let context = NSGraphicsContext.current else {
            return
        }

        context.saveGraphicsState()
        defer {
            context.restoreGraphicsState()
        }

        color.setStroke()

        let path = nsBezierPath()
        path.lineWidth = lineWidth
        path.lineCapStyle = lineCapStyle
        path.lineJoinStyle = lineJoinStyle
        path.miterLimit = miterLimit
        path.transform(using: transform)
        path.stroke()
    }

    /// Returns a stroked version of the path.
    func stroked(
        lineWidth: CGFloat,
        lineCap: CGLineCap = .butt,
        lineJoin: CGLineJoin = .miter,
        miterLimit: CGFloat = 10.0,
        transform: CGAffineTransform = .identity
    ) -> Path {
        let stroked = cgPath().copy(
            strokingWithWidth: lineWidth,
            lineCap: lineCap,
            lineJoin: lineJoin,
            miterLimit: miterLimit,
            transform: transform
        )
        return Path(cgPath: stroked)
    }
}
