//
//  CWColorWellPullDownSwatchSegment.swift
//  ColorWellKit
//

import AppKit

// MARK: - CWColorWellPullDownSwatchSegment

/// A segment that displays a color swatch with the color well's current
/// color selection, and that triggers a pull-down action when pressed.
class CWColorWellPullDownSwatchSegment: CWColorWellSwatchSegment {

    // MARK: Properties

    private var mouseEnterExitTrackingArea: NSTrackingArea?

    var canPerformAction: Bool {
        if let colorWell {
            if colorWell.secondaryAction != nil && colorWell.secondaryTarget != nil {
                // we have a secondary action and a target to perform it; this
                // gets priority over the popover configuration, so no need to
                // perform further checks
                return true
            }
            return !colorWell.swatchColors.isEmpty
        }
        return false
    }

    override var draggingInformation: DraggingInformation {
        didSet {
            // make sure the caret disappears when dragging starts
            if draggingInformation.isDragging {
                state = .default
            }
        }
    }

    // MARK: Methods

    override class func performAction(for segment: CWColorWellSegment) -> Bool {
        guard let colorWell = segment.colorWell else {
            return false
        }

        if
            let segment = segment as? Self,
            !segment.canPerformAction || NSEvent.modifierFlags.contains(.shift)
        {
            // can't perform the standard action; treat like a toggle segment
            return CWColorWellToggleSegment.performAction(for: segment)
        }

        if
            let secondaryAction = colorWell.secondaryAction,
            let secondaryTarget = colorWell.secondaryTarget
        {
            // secondary action takes priority over showing the popover
            return NSApp.sendAction(secondaryAction, to: secondaryTarget, from: colorWell)
        }

        return colorWell.makeAndShowPopover(relativeTo: segment)
    }

    private func drawBorder() {
        guard let context = NSGraphicsContext.current else {
            return
        }

        context.saveGraphicsState()
        defer {
            context.restoreGraphicsState()
        }

        let lineWidth: CGFloat = 0.5
        let insetRect = bounds.insetBy(dx: lineWidth / 2, dy: lineWidth / 2)
        segmentPath(insetRect).stroke(with: borderColor, lineWidth: lineWidth)
    }

    private func drawCaret() {
        guard
            canPerformAction,
            let context = NSGraphicsContext.current
        else {
            return
        }

        // caret needs to be drawn differently depending on the control size;
        // these values aren't based on any real logic, just what looks good
        let (bgBounds, caretBounds, lineWidth): (NSRect, NSRect, CGFloat) = {
            let (bgDimension, lineWidth, sizeFactor, padding): (CGFloat, CGFloat, CGFloat, CGFloat) = {
                // lazy declarations prevent reallocation on first reassignment
                lazy var bgDimension: CGFloat = 12.0
                lazy var lineWidth: CGFloat = 1.5
                lazy var sizeFactor: CGFloat = 2.0
                lazy var padding: CGFloat = 4.0

                switch colorWell?.controlSize {
                case .large, .regular, .none:
                    break // no change
                case .small:
                    bgDimension = 10.0
                    lineWidth = 1.33
                    sizeFactor = 1.85
                    padding = 3.0
                case .mini:
                    bgDimension = 9.0
                    lineWidth = 1.25
                    sizeFactor = 1.75
                    padding = 2.0
                @unknown default:
                    break
                }

                return (bgDimension, lineWidth, sizeFactor, padding)
            }()

            let bgBounds = NSRect(
                x: bounds.maxX - bgDimension - padding,
                y: bounds.midY - bgDimension / 2,
                width: bgDimension,
                height: bgDimension
            )
            let caretBounds = with((bgDimension - lineWidth) / sizeFactor) { dimension in
                let size = NSSize(
                    width: dimension,
                    height: dimension / 2
                )
                let origin = NSPoint(
                    x: bgBounds.midX - (size.width / 2),
                    y: bgBounds.midY - (size.height / 2) - (lineWidth / 4)
                )
                return NSRect(origin: origin, size: size)
            }

            return (bgBounds, caretBounds, lineWidth)
        }()

        context.saveGraphicsState()
        defer {
            context.restoreGraphicsState()
        }

        NSColor(white: 0, alpha: 0.25).setFill()
        NSBezierPath(ovalIn: bgBounds).fill()

        let caretPath = Path(elements: [
            .move(to: NSPoint(x: caretBounds.minX, y: caretBounds.maxY)),
            .line(to: NSPoint(x: caretBounds.midX, y: caretBounds.minY)),
            .line(to: NSPoint(x: caretBounds.maxX, y: caretBounds.maxY)),
        ]).nsBezierPath()

        caretPath.lineCapStyle = .round
        caretPath.lineJoinStyle = .round
        caretPath.lineWidth = lineWidth

        NSColor.white.setStroke()
        caretPath.stroke()
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        drawBorder()
        if state == .hover {
            drawCaret()
        }
    }

    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        guard isEnabled else {
            return
        }
        state = .hover
    }

    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        guard isEnabled else {
            return
        }
        state = .default
    }

    override func needsDisplayOnStateChange(_ state: State) -> Bool {
        switch state {
        case .hover, .default: true
        case .highlight, .pressed: false
        }
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let mouseEnterExitTrackingArea {
            removeTrackingArea(mouseEnterExitTrackingArea)
        }
        let mouseEnterExitTrackingArea = NSTrackingArea(
            rect: bounds,
            options: [
                .activeInKeyWindow,
                .mouseEnteredAndExited,
            ],
            owner: self
        )
        addTrackingArea(mouseEnterExitTrackingArea)
        self.mouseEnterExitTrackingArea = mouseEnterExitTrackingArea
    }
}

// MARK: - CWColorWellSinglePullDownSwatchSegment

/// A pull down swatch segment that fills its color well.
class CWColorWellSinglePullDownSwatchSegment: CWColorWellPullDownSwatchSegment {
    override class var edge: Edge? { nil }

    override var borderColor: NSColor { .placeholderTextColor }
}

// MARK: - CWColorWellPartialPullDownSwatchSegment

/// A pull down swatch segment that does not fill its color well.
class CWColorWellPartialPullDownSwatchSegment: CWColorWellPullDownSwatchSegment {
    override class var edge: Edge? { .leading }
}
