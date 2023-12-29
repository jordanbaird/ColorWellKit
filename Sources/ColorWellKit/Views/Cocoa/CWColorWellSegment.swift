//
//  CWColorWellSegment.swift
//  ColorWellKit
//

import AppKit

// MARK: - CWColorWellSegment

/// A view that draws a segmented portion of a color well.
class CWColorWellSegment: NSView {
    /// A type that represents the state of a color well segment.
    enum State {
        case `default`
        case hover
        case highlight
        case pressed
    }

    /// The edge of a color well where segments of this type are drawn.
    ///
    /// The value of this property specifies how the color well should be
    /// drawn, specifically, whether it should be drawn as a continuous
    /// rounded rectangle, or as a partial rounded rectangle that makes up
    /// a segment in the final shape, with one of its sides drawn with a
    /// flat edge to match up with the segment on the opposite side.
    ///
    /// Any value other than `nil` indicates that the segment should be
    /// drawn as a partial rounded rectangle. A `nil` value indicates that
    /// the segment fills the entire bounds of the color well, and should
    /// be drawn as a continuous rounded rectangle.
    ///
    /// The default value for the base segment class is `nil`, and should
    /// be overridden by subclasses.
    class var edge: Edge? { nil }

    weak var colorWell: CWColorWell?

    /// The current and previous states of the segment.
    var backingStates = (current: State.default, previous: State.default)

    /// The current state of the segment.
    ///
    /// Updating this property displays the segment, if the value returned
    /// from `needsDisplayOnStateChange(_:)` is `true`.
    var state: State {
        get {
            backingStates.current
        }
        set {
            backingStates = (newValue, state)
            if needsDisplayOnStateChange(newValue) {
                needsDisplay = true
            }
        }
    }

    /// Passthrough of `isActive` on `colorWell`.
    var isActive: Bool {
        colorWell?.isActive ?? false
    }

    /// Passthrough of `isEnabled` on `colorWell`.
    var isEnabled: Bool {
        colorWell?.isEnabled ?? false
    }

    /// The default fill color for a color well segment.
    var segmentColor: NSColor {
        switch ColorScheme.current {
        case .light: .controlColor
        case .dark: .selectedControlColor
        }
    }

    /// The fill color for a highlighted color well segment.
    var highlightedSegmentColor: NSColor {
        switch ColorScheme.current {
        case .light: segmentColor.blending(fraction: 0.5, of: .selectedControlColor)
        case .dark: segmentColor.blending(fraction: 0.2, of: .highlightColor)
        }
    }

    /// The fill color for a selected color well segment.
    var selectedSegmentColor: NSColor {
        switch ColorScheme.current {
        case .light: .selectedControlColor
        case .dark: segmentColor.withAlphaComponent(segmentColor.alphaComponent + 0.25)
        }
    }

    /// The unaltered fill color of the segment.
    var rawColor: NSColor { segmentColor }

    /// The color that is displayed directly in the segment.
    var displayColor: NSColor { rawColor }

    override var acceptsFirstResponder: Bool { true }

    override var needsPanelToBecomeKey: Bool { false }

    override var focusRingMaskBounds: NSRect { bounds }

    /// Creates a segment for the given color well.
    init(colorWell: CWColorWell) {
        super.init(frame: .zero)
        self.colorWell = colorWell
        self.wantsLayer = true
        updateForCurrentActiveState(colorWell.isActive)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Performs a predefined action for this segment class using the given segment.
    ///
    /// Subclasses should override this method to provide their own custom behavior.
    /// It is defined as a class method to allow a given implementation to delegate
    /// to an implementation belonging to a different segment class.
    ///
    /// - Parameter segment: A segment to perform the action with.
    ///
    /// - Returns: A Boolean value indicating whether the action was successfully
    ///   performed.
    class func performAction(for segment: CWColorWellSegment) -> Bool { false }

    /// Performs the segment's action using the given key event, after
    /// performing validation on the key event to ensure it can be used
    /// to perform the action.
    ///
    /// The segment must be enabled in order to successfully perform its
    /// action. The event must be a key-down event, and its `characters`
    /// property must consist of a single space (U+0020) character. If
    /// these conditions are not met, or performing the action otherwise
    /// fails, this method returns `false`.
    ///
    /// - Parameter event: A key event to validate.
    ///
    /// - Returns: A Boolean value indicating whether the action was
    ///   successfully performed.
    func validateAndPerformAction(withKeyEvent event: NSEvent) -> Bool {
        if
            isEnabled,
            event.type == .keyDown,
            event.characters == "\u{0020}" // space
        {
            return Self.performAction(for: self)
        }
        return false
    }

    /// Updates the state of the segment to match the specified active state.
    func updateForCurrentActiveState(_ isActive: Bool) { }

    /// Invoked to return whether the segment should be redrawn after its state changes.
    func needsDisplayOnStateChange(_ state: State) -> Bool { false }

    /// Returns the path to draw the segment in the given rectangle.
    func segmentPath(_ rect: NSRect) -> Path {
        Path.segmentPath(
            rect: rect,
            controlSize: colorWell?.controlSize,
            segmentType: Self.self
        )
    }

    override func draw(_ dirtyRect: NSRect) {
        segmentPath(bounds).fill(with: displayColor)
    }

    override func drawFocusRingMask() {
        segmentPath(focusRingMaskBounds).fill(with: .black)
    }

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        guard isEnabled else {
            return
        }
        state = .highlight
    }

    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        guard
            isEnabled,
            frameConvertedToWindow.contains(event.locationInWindow)
        else {
            return
        }
        _ = Self.performAction(for: self)
    }

    override func keyDown(with event: NSEvent) {
        if !validateAndPerformAction(withKeyEvent: event) {
            super.keyDown(with: event)
        }
    }

    override func accessibilityParent() -> Any? {
        return colorWell
    }

    override func accessibilityPerformPress() -> Bool {
        Self.performAction(for: self)
    }

    override func accessibilityRole() -> NSAccessibility.Role? {
        return .button
    }

    override func isAccessibilityElement() -> Bool {
        return true
    }
}

// MARK: - CWSwatchSegment

/// A segment that displays a color swatch with the color well's current
/// color selection.
class CWSwatchSegment: CWColorWellSegment {
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

    var draggingInformation = DraggingInformation()

    var borderColor: NSColor {
        let displayColor = displayColor
        let component = min(displayColor.averageBrightness, displayColor.alphaComponent)
        let limitedComponent = min(component, 0.3)
        let white = 1 - limitedComponent
        let alpha = min(limitedComponent * 1.3, 0.7)
        return NSColor(white: white, alpha: alpha)
    }

    override var rawColor: NSColor {
        colorWell?.color ?? super.rawColor
    }

    override var displayColor: NSColor {
        super.displayColor.usingColorSpace(.displayP3) ?? super.displayColor
    }

    override var acceptsFirstResponder: Bool { false }

    override init(colorWell: CWColorWell) {
        super.init(colorWell: colorWell)
        registerForDraggedTypes([.color])
    }

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

    override func isAccessibilityElement() -> Bool {
        return false
    }
}

// MARK: - CWBorderedSwatchSegment

/// A segment that displays a color swatch with the color well's current
/// color selection, and that toggles the color panel when pressed.
class CWBorderedSwatchSegment: CWSwatchSegment {
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
        case .light: super.borderColor.blending(fraction: 0.25, of: .controlTextColor)
        case .dark: super.borderColor
        }
    }

    override class func performAction(for segment: CWColorWellSegment) -> Bool {
        CWToggleSegment.performAction(for: segment)
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
            roundedRect: bounds.inset(by: inset),
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

// MARK: - CWPullDownSwatchSegment

/// A segment that displays a color swatch with the color well's current
/// color selection, and that triggers a pull-down action when pressed.
class CWPullDownSwatchSegment: CWSwatchSegment {
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

    override class func performAction(for segment: CWColorWellSegment) -> Bool {
        guard let colorWell = segment.colorWell else {
            return false
        }

        if
            let segment = segment as? Self,
            !segment.canPerformAction || NSEvent.modifierFlags.contains(.shift)
        {
            // can't perform the standard action; treat like a toggle segment
            return CWToggleSegment.performAction(for: segment)
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

// MARK: - CWSinglePullDownSwatchSegment

/// A pull down swatch segment that fills its color well.
class CWSinglePullDownSwatchSegment: CWPullDownSwatchSegment {
    override class var edge: Edge? { nil }

    override var borderColor: NSColor { .placeholderTextColor }
}

// MARK: - CWPartialPullDownSwatchSegment

/// A pull down swatch segment that does not fill its color well.
class CWPartialPullDownSwatchSegment: CWPullDownSwatchSegment {
    override class var edge: Edge? { .leading }
}

// MARK: - CWToggleSegment

/// A segment that toggles the system color panel when pressed.
class CWToggleSegment: CWColorWellSegment {
    private enum Images {
        static let defaultImage: NSImage = {
            // force unwrap is okay here, as the image is an AppKit builtin
            // swiftlint:disable:next force_unwrapping
            let image = NSImage(named: NSImage.touchBarColorPickerFillName)!

            let minDimension = min(image.size.width, image.size.height)
            let croppedSize = NSSize(width: minDimension, height: minDimension)
            let croppedRect = NSRect(origin: .zero, size: croppedSize)
                .centered(in: NSRect(origin: .zero, size: image.size))

            return NSImage(size: croppedSize, flipped: false) { bounds in
                image.draw(in: bounds, from: croppedRect, operation: .copy, fraction: 1)
                return true
            }
        }()

        static let enabledImageForDarkAppearance = defaultImage.tinted(to: .white, fraction: 1 / 3)

        static let enabledImageForLightAppearance = defaultImage.tinted(to: .black, fraction: 1 / 5)

        static let disabledImageForDarkAppearance = defaultImage.tinted(to: .gray, fraction: 1 / 3).withOpacity(0.5)

        static let disabledImageForLightAppearance = defaultImage.tinted(to: .gray, fraction: 1 / 5).withOpacity(0.5)
    }

    static let widthConstant: CGFloat = 20

    override class var edge: Edge? { .trailing }

    override var rawColor: NSColor {
        switch state {
        case .highlight:
            return highlightedSegmentColor
        case .pressed:
            return selectedSegmentColor
        default:
            return segmentColor
        }
    }

    override init(colorWell: CWColorWell) {
        super.init(colorWell: colorWell)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalToConstant: Self.widthConstant).isActive = true
    }

    override class func performAction(for segment: CWColorWellSegment) -> Bool {
        guard let colorWell = segment.colorWell else {
            return false
        }
        if colorWell.isActive {
            colorWell.deactivate()
        } else {
            colorWell.activateAutoExclusive()
        }
        return true
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        guard
            let context = NSGraphicsContext.current,
            let colorWell
        else {
            return
        }

        context.saveGraphicsState()
        defer {
            context.restoreGraphicsState()
        }

        let imageRect: NSRect = {
            let (pad, width, height) = (5.5, bounds.width, bounds.height)
            var dimension = min(max(height - pad * 2, width - pad), width - 1)
            switch colorWell.controlSize {
            case .large, .regular:
                break // no change
            case .small:
                dimension -= 3
            case .mini:
                dimension -= 4
            @unknown default:
                break
            }
            return NSRect(
                x: bounds.midX - dimension / 2,
                y: bounds.midY - dimension / 2,
                width: dimension,
                height: dimension
            )
        }()

        let image: NSImage = {
            switch ColorScheme.current {
            case .light where isEnabled:
                if state == .highlight {
                    return Images.enabledImageForLightAppearance
                }
                return Images.defaultImage
            case .light:
                return Images.disabledImageForLightAppearance
            case .dark where isEnabled:
                if state == .highlight {
                    return Images.enabledImageForDarkAppearance
                }
                return Images.defaultImage
            case .dark:
                return Images.disabledImageForDarkAppearance
            }
        }()

        NSBezierPath(ovalIn: imageRect).addClip()
        image.draw(in: imageRect)
    }

    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        guard isEnabled else {
            return
        }
        if frameConvertedToWindow.contains(event.locationInWindow) {
            state = .highlight
        } else if isActive {
            state = .pressed
        } else {
            state = .default
        }
    }

    override func updateForCurrentActiveState(_ isActive: Bool) {
        state = isActive ? .pressed : .default
    }

    override func needsDisplayOnStateChange(_ state: State) -> Bool {
        switch state {
        case .highlight, .pressed, .default:
            return true
        case .hover:
            return false
        }
    }

    override func accessibilityLabel() -> String? {
        return "color picker"
    }
}
