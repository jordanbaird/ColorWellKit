//
//  ColorWellBorderedSwatchSegment.swift
//  ColorWellKit
//

import AppKit

/// A segment that displays a color swatch with the color well's current
/// color selection, and that toggles the color panel when pressed.
class ColorWellBorderedSwatchSegment: ColorWellSwatchSegment {

    // MARK: Properties

    override class var edge: Edge? { nil }

    var bezelColor: NSColor {
        let bezelColor: NSColor = switch state {
        case .highlight, .pressed:
            switch ColorScheme.current {
            case .light:
                selectedSegmentColor
            case .dark:
                .highlightColor
            }
        default:
            segmentColor
        }
        guard isEnabled else {
            let alphaComponent = max(bezelColor.alphaComponent - 0.5, 0.1)
            return bezelColor.withAlphaComponent(alphaComponent)
        }
        return bezelColor
    }

    override var borderColor: NSColor {
        switch ColorScheme.current {
        case .light:
            super.borderColor.blending(fraction: 0.25, of: .controlTextColor)
        case .dark:
            super.borderColor
        }
    }

    // MARK: Methods

    override class func performAction(for segment: ColorWellSegment) -> Bool {
        ColorWellToggleSegment.performAction(for: segment)
    }

    override func drawSwatch() {
        guard let context = NSGraphicsContext.current else {
            return
        }

        context.saveGraphicsState()
        defer {
            context.restoreGraphicsState()
        }

        segmentPath(bounds).fill(with: bezelColor)

        let (inset, radius) = with(colorWell?.controlSize ?? .regular) { controlSize in
            let standardInset: CGFloat = 3
            let standardRadius: CGFloat = 2
            return switch controlSize {
            case .large:
                (standardInset + 0.25, standardRadius + 0.2)
            case .regular:
                (standardInset, standardRadius)
            case .small:
                (standardInset - 0.75, standardRadius - 0.6)
            case .mini:
                (standardInset - 1, standardRadius - 0.8)
            @unknown default:
                (standardInset, standardRadius)
            }
        }

        let clippingPath = NSBezierPath(
            roundedRect: bounds.insetBy(inset),
            xRadius: radius,
            yRadius: radius
        )

        clippingPath.lineWidth = 1
        clippingPath.addClip()

        displayColor.drawSwatch(in: bounds)

        borderColor.setStroke()
        clippingPath.stroke()
    }

    override func updateForCurrentActiveState(_ isActive: Bool) {
        state = isActive ? .pressed : .default
    }

    override func needsDisplayOnStateChange(_ state: State) -> Bool {
        state != .hover
    }
}
