//
//  ColorWell.swift
//  ColorWellKit
//

import AppKit

/// A control that displays a user-selectable color value.
public class ColorWell: _ColorWellBaseControl {

    // MARK: Static Properties

    private static let exclusivityLock = NSRecursiveLock()

    private static let popoverStorage = ObjectAssociation<ColorWellPopover>()

    // MARK: Instance Properties

    private var isExclusive = true

    /// The color well's delegate object.
    public weak var delegate: ColorWellDelegate?

    /// A Boolean value that indicates whether the color well supports being
    /// included in group selections.
    ///
    /// Users can make group selections by holding the `Shift` key while making
    /// a selection. If a newly-selected color well's `allowsMultipleSelection`
    /// property is `true` (the default), the selected color well becomes part
    /// of the current group selection. If no other color wells are selected, a
    /// new group selection is created.
    @objc dynamic
    public var allowsMultipleSelection: Bool = true

    /// A configuration that specifies the appearance of the user-selectable
    /// swatches in the color well’s popover.
    ///
    /// If the ``secondaryAction`` and ``secondaryTarget`` properties have
    /// been set, the action specified by those properties will be invoked
    /// instead of the popover being shown.
    ///
    /// If this value is `nil`, and the secondary action and target properties
    /// have not been set, the color well will not show its popover, and will
    /// instead defer to opening the system color panel.
    ///
    /// The default value of this property is ``PopoverConfiguration-swift.struct/default``.
    public var popoverConfiguration: PopoverConfiguration? = .default

    /// The action to perform when the color area of the color well is pressed.
    ///
    /// By default, color wells with the ``Style-swift.enum/swatches`` or
    /// ``Style-swift.enum/expanded`` style display a popover with a grid of
    /// color swatches when the color area is pressed. If you specify a value
    /// for this property and the ``secondaryTarget`` property, clicks inside
    /// the color area execute your custom action method instead.
    public var secondaryAction: Selector?

    /// The target object that defines the action to perform when the color
    /// area of the color well is pressed.
    ///
    /// By default, color wells with the ``Style-swift.enum/swatches`` or
    /// ``Style-swift.enum/expanded`` style display a popover with a grid of
    /// color swatches when the color area is pressed. If you specify a value
    /// for this property and the ``secondaryAction`` property, clicks inside
    /// the color area execute your custom action method instead.
    public var secondaryTarget: AnyObject?

    /// The color well's color.
    ///
    /// Setting this value immediately updates the visual state of the color
    /// well. If the color well is active, the system color panel's color is
    /// updated to match the new value.
    @objc dynamic
    public var color: NSColor {
        get {
            backingStorage.color
        }
        set {
            updateColor(newValue, options: [])
        }
    }

    /// A Boolean value that indicates whether the color well is currently
    /// active.
    @objc dynamic
    public var isActive: Bool {
        get {
            NSColorPanel.shared.isAttached(self)
        }
        set {
            let shouldActivate = isEnabled && newValue
            defer {
                for segment in layoutView.segments {
                    segment.updateForCurrentActiveState(shouldActivate)
                }
                if shouldActivate {
                    NSColorPanel.shared.orderFront(self)
                }
            }
            if shouldActivate {
                if isExclusive && allowsMultipleSelection {
                    NSColorPanel.shared.enforceExclusivity(of: self)
                }
                NSColorPanel.shared.attach(self)
                delegate?.colorWellDidActivate(self)
            } else {
                NSColorPanel.shared.detach(self)
                delegate?.colorWellDidDeactivate(self)
            }
        }
    }

    /// The appearance and behavior style to apply to the color well.
    ///
    /// The value of this property determines how the color well is displayed,
    /// and specifies how it should respond when someone interacts with it.
    ///
    /// For a list of possible values, see ``Style-swift.enum``.
    @objc dynamic
    public var style: Style {
        get {
            backingStorage.style
        }
        set {
            backingStorage.style = newValue
            invalidateIntrinsicContentSize()
            needsDisplay = true
        }
    }

    // MARK: Convenience Initializers

    /// Creates a color well with the specified color.
    ///
    /// - Parameter color: The initial color of the created color well.
    public convenience init(color: NSColor) {
        self.init()
        self.color = color
    }

    /// Creates a color well with the specified style.
    ///
    /// - Parameter style: The style of the created color well.
    public convenience init(style: Style) {
        self.init()
        self.style = style
    }

    // MARK: Public Instance Methods

    /// Activates the color well and displays the system color panel.
    ///
    /// Both elements will remain synchronized until either the color panel is closed
    /// or the color well is deactivated.
    ///
    /// - Parameter exclusive: A Boolean value that indicates whether the color well
    ///   is activated with exclusive access to the system color panel. Passing `true`
    ///   causes all other active color wells to be deactivated. Passing `false`
    ///   activates the color well alongside any other color wells that are currently
    ///   active. Note that color well exclusivity is only relevant during activation,
    ///   and is not enforced after this method returns.
    public func activate(exclusive: Bool) {
        withExclusivityLock(exclusive) { isActive = true }
    }

    /// Deactivates the color well, detaching it from the system color panel.
    ///
    /// Until the color well is activated again, changes to the color panel will not
    /// affect the color well's state.
    public func deactivate() {
        withExclusivityLock(isExclusive) { isActive = false }
    }

    // MARK: Private/Internal Instance Methods

    /// Performs the given closure while locking the exclusivity of the color well
    /// to the given state in a thread-safe manner.
    private func withExclusivityLock<T>(
        _ isExclusive: @autoclosure () -> Bool,
        body: () throws -> T
    ) rethrows -> T {
        Self.exclusivityLock.lock()
        let cachedIsExclusive = self.isExclusive
        self.isExclusive = isExclusive()
        defer {
            self.isExclusive = cachedIsExclusive
            Self.exclusivityLock.unlock()
        }
        return try body()
    }

    @objc(deactivate) // exposed to Objective-C as `deactivate`
    private func objcDeactivate() {
        deactivate()
    }

    /// Activates the color well, automatically determining whether it should be
    /// activated in an exclusive state.
    func activateAutoExclusive() {
        activate(exclusive: !NSEvent.modifierFlags.contains(.shift))
    }

    /// Creates a popover according to the color well's popover configuration and
    /// shows it relative to the given segment.
    ///
    /// - Parameter segment: The segment in the color well relative to which the
    ///   popover should be shown. If the segment does not belong to the color well,
    ///   this method returns `false`.
    ///
    /// - Returns: `true` on success, `false` otherwise.
    @discardableResult
    func makeAndShowPopover(relativeTo segment: ColorWellSegment) -> Bool {
        if Self.popoverStorage[self] != nil {
            // a popover is already being shown
            return false
        }
        guard
            let popoverConfiguration,
            layoutView.segments.contains(segment)
        else {
            return false
        }
        let popover = ColorWellPopover(colorWell: self, configuration: popoverConfiguration)

        // the popover is removed from storage when it is closed; we use the
        // presence of the popover to determine whether the next call to this
        // method should succeed or fail
        Self.popoverStorage[self] = popover

        popover.show(relativeTo: segment.frame, of: segment, preferredEdge: .minY)
        return true
    }

    /// Closes and removes the color well's popover from storage.
    func freePopover() {
        Self.popoverStorage[self]?.close()
        Self.popoverStorage[self] = nil
    }

    // MARK: Overridden Instance Methods

    override func updateColor(_ newColor: NSColor?, options: ColorUpdateOptions) {
        let newColor = newColor ?? .black

        guard backingStorage.color != newColor else {
            return
        }

        // set up a series of deferred blocks to execute in reverse order
        // once the color has been set
        var deferredBlocks = [(ColorWell) -> Void]()

        // these get executed regardless of the options passed in
        deferredBlocks.append { colorWell in
            let colorPanel = NSColorPanel.shared
            if
                colorPanel.isMainAttachedObject(colorWell),
                colorPanel.color != colorWell.color
            {
                colorPanel.color = colorWell.color
            }
        }
        deferredBlocks.append { colorWell in
            colorWell.layoutView.setSegmentsNeedDisplay(true)
        }

        if options.contains(.sendAction) {
            deferredBlocks.append { colorWell in
                colorWell.sendAction(colorWell.action, to: colorWell.target)
            }
        }
        if options.contains(.informObservers) {
            willChangeValue(for: \.color)
            deferredBlocks.append { colorWell in
                colorWell.didChangeValue(for: \.color)
            }
        }
        if options.contains(.informDelegate) {
            delegate?.colorWellWillChangeColor(self, to: newColor)
            deferredBlocks.append { colorWell in
                colorWell.delegate?.colorWellDidChangeColor(colorWell)
            }
        }

        backingStorage.color = newColor

        while let block = deferredBlocks.popLast() {
            block(self)
        }
    }
}
