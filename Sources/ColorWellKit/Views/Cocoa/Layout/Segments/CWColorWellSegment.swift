//
//  CWColorWellSegment.swift
//  ColorWellKit
//

import AppKit

/// A view that draws a segmented portion of a color well.
class CWColorWellSegment: NSView {

    // MARK: Types

    /// A type that represents the state of a color well segment.
    enum State {
        /// The segment is being hovered over.
        case hover

        /// The segment is highlighted.
        case highlight

        /// The segment is pressed.
        case pressed

        /// The default, idle state of a segment.
        case `default`
    }

    // MARK: Type Properties

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

    // MARK: Instance Properties

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
    var isActive: Bool { colorWell?.isActive ?? false }

    /// Passthrough of `isEnabled` on `colorWell`.
    var isEnabled: Bool { colorWell?.isEnabled ?? false }

    /// The default fill color for a color well segment.
    var segmentColor: NSColor {
        switch ColorScheme.current {
        case .light:
            return .controlColor
        case .dark:
            return .selectedControlColor
        }
    }

    /// The fill color for a highlighted color well segment.
    var highlightedSegmentColor: NSColor {
        switch ColorScheme.current {
        case .light:
            return segmentColor.blending(fraction: 0.5, of: .selectedControlColor)
        case .dark:
            return segmentColor.blending(fraction: 0.2, of: .highlightColor)
        }
    }

    /// The fill color for a selected color well segment.
    var selectedSegmentColor: NSColor {
        switch ColorScheme.current {
        case .light:
            return .selectedControlColor
        case .dark:
            return segmentColor.withAlphaComponent(segmentColor.alphaComponent + 0.25)
        }
    }

    /// The unaltered fill color of the segment.
    var rawColor: NSColor { segmentColor }

    /// The color that is displayed directly in the segment.
    var displayColor: NSColor { rawColor }

    // MARK: Initializers

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

    // MARK: Type Methods

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

    // MARK: Instance Methods

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
}

// MARK: Overridden Properties
extension CWColorWellSegment {
    override var acceptsFirstResponder: Bool { true }

    override var needsPanelToBecomeKey: Bool { false }

    override var focusRingMaskBounds: NSRect { bounds }
}

// MARK: Overridden Methods
extension CWColorWellSegment {
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

    // MARK: Accessibility

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
