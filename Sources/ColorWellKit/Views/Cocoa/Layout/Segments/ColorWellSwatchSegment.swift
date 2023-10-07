//
//  ColorWellSwatchSegment.swift
//  ColorWellKit
//

import AppKit

/// A segment that displays a color swatch with the color well's current
/// color selection.
class ColorWellSwatchSegment: ColorWellSegment {

    // MARK: Types

    /// Dragging information associated with a color well segment.
    struct DraggingInformation {
        /// The default values for this instance.
        private let defaults: (threshold: CGFloat, isDragging: Bool, offset: CGSize)

        /// The amount of movement that must occur before a dragging
        /// session can start.
        var threshold: CGFloat

        /// A Boolean value that indicates whether a drag is currently
        /// in progress.
        var isDragging: Bool

        /// The accumulated offset of the current series of dragging
        /// events.
        var offset: CGSize

        /// A Boolean value that indicates whether the current dragging
        /// information is valid for starting a dragging session.
        var isValid: Bool {
            hypot(offset.width, offset.height) >= threshold
        }

        /// Creates an instance with the given values.
        ///
        /// The values that are provided here will be cached, and used
        /// to reset the instance.
        init(
            threshold: CGFloat = 4,
            isDragging: Bool = false,
            offset: CGSize = CGSize()
        ) {
            self.defaults = (threshold, isDragging, offset)
            self.threshold = threshold
            self.isDragging = isDragging
            self.offset = offset
        }

        /// Resets the dragging information to its default values.
        mutating func reset() {
            self = DraggingInformation(
                threshold: defaults.threshold,
                isDragging: defaults.isDragging,
                offset: defaults.offset
            )
        }

        /// Updates the segment's dragging offset according to the x and y
        /// deltas of the given event.
        mutating func updateOffset(with event: NSEvent) {
            offset.width += event.deltaX
            offset.height += event.deltaY
        }
    }

    // MARK: Properties

    var draggingInformation = DraggingInformation()

    var borderColor: NSColor {
        with(displayColor) { displayColor in
            let component = min(displayColor.averageBrightness, displayColor.alphaComponent)
            let limitedComponent = min(component, 0.3)
            let white = 1 - limitedComponent
            let alpha = min(limitedComponent * 1.3, 0.7)
            return NSColor(white: white, alpha: alpha)
        }
    }

    override var rawColor: NSColor {
        colorWell?.color ?? super.rawColor
    }

    override var displayColor: NSColor {
        super.displayColor.usingColorSpace(.displayP3) ?? super.displayColor
    }

    override var acceptsFirstResponder: Bool { false }

    // MARK: Initializers

    override init(colorWell: ColorWell) {
        super.init(colorWell: colorWell)
        registerForDraggedTypes([.color])
    }

    // MARK: Methods

    /// Draws the segment's swatch.
    @objc dynamic
    func drawSwatch() {
        guard let context = NSGraphicsContext.current else {
            return
        }

        context.saveGraphicsState()
        defer {
            context.restoreGraphicsState()
        }

        // workaround for the clipping path affecting the border of the swatch: draw the
        // swatch as an image before clipping, then clip the image instead of the swatch
        let swatchImage = NSImage(size: bounds.size, flipped: false) { [weak displayColor] bounds in
            guard let displayColor else {
                return false
            }
            displayColor.drawSwatch(in: bounds)
            return true
        }

        segmentPath(bounds).nsBezierPath().addClip()
        swatchImage.draw(in: bounds)
    }

    override func draw(_ dirtyRect: NSRect) {
        drawSwatch()
    }

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        draggingInformation.reset()
    }

    override func mouseUp(with event: NSEvent) {
        defer {
            draggingInformation.reset()
        }
        guard !draggingInformation.isDragging else {
            return
        }
        super.mouseUp(with: event)
    }

    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)

        guard isEnabled else {
            return
        }

        draggingInformation.updateOffset(with: event)

        guard
            draggingInformation.isValid,
            let color = colorWell?.color
        else {
            return
        }

        draggingInformation.isDragging = true
        state = backingStates.previous

        let colorForDragging = color.createArchivedCopy()
        NSColorPanel.dragColor(colorForDragging, with: event, from: self)
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        guard
            isEnabled,
            let types = sender.draggingPasteboard.types,
            types.contains(where: { registeredDraggedTypes.contains($0) })
        else {
            return []
        }
        return .move
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        if
            let colorWell,
            let color = NSColor(from: sender.draggingPasteboard)
        {
            colorWell.updateColor(color, options: [
                .informDelegate,
                .informObservers,
                .sendAction,
            ])
            return true
        }
        return false
    }

    // MARK: Accessibility

    override func isAccessibilityElement() -> Bool {
        return false
    }
}
