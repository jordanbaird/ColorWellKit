//
//  CWColorWellBaseControl.swift
//  ColorWellKit
//

import AppKit

/// A base control that contains some default functionality for use in the
/// main ``CWColorWell`` class.
///
/// The public ``CWColorWell`` class inherits from this class. The underscore
/// in front of the name of this class indicates that it is a private API,
/// and shouldn't be used. This class exists to enable public properties and
/// methods to be overridden without polluting the package's documentation,
/// and will probably continue to exist until a better solution is found.
public class _CWColorWellBaseControl: NSControl {

    // MARK: Types

    struct BackingStorage {
        static let defaultColor = NSColor(red: 1, green: 1, blue: 1, alpha: 1)

        static let defaultStyle = CWColorWell.Style.default

        static let defaultSize = NSSize(width: 38, height: 24)

        var color = Self.defaultColor

        var style = Self.defaultStyle

        var isEnabled = true

        var cell: NSCell?
    }

    /// Options that describe the side effects that should occur when a
    /// color well updates its color.
    struct ColorUpdateOptions: OptionSet {
        let rawValue: UInt

        /// The color well will send a message to its delegate before and
        /// after the change.
        static let informDelegate  = ColorUpdateOptions(rawValue: 1 << 0)

        /// The color well will send a notification before and after the
        /// change to any objects observing its color value.
        static let informObservers = ColorUpdateOptions(rawValue: 1 << 1)

        /// The color well will send its action message to its target.
        static let sendAction      = ColorUpdateOptions(rawValue: 1 << 2)
    }

    // MARK: Static Properties

    private static let colorPanelObservations: [NSKeyValueObservation] = [
        NSColorPanel.shared.observe(\.color) { colorPanel, _ in
            for case let colorWell as CWColorWell in colorPanel.attachedObjects {
                colorWell.updateColor(colorPanel.color, options: [
                    .informDelegate,
                    .informObservers,
                    .sendAction,
                ])
            }
        },
        NSColorPanel.shared.observe(\.isVisible) { colorPanel, _ in
            if !colorPanel.isVisible {
                for case let colorWell as CWColorWell in colorPanel.attachedObjects {
                    colorWell.deactivate()
                }
            }
        },
    ]

    // MARK: Instance Properties

    final var backingStorage = BackingStorage()

    final var layoutView: CWColorWellLayoutView {
        enum Context {
            static let storage = ObjectAssociation<CWColorWellLayoutView>()
        }
        // force cast is okay here; at this point it should be guaranteed
        // that self is an instance of CWColorWell or one of its subclasses
        let colorWell = self as! CWColorWell // swiftlint:disable:this force_cast
        if let layoutView = Context.storage[colorWell] {
            return layoutView
        }
        let layoutView = CWColorWellLayoutView(colorWell: colorWell)
        Context.storage[colorWell] = layoutView
        return layoutView
    }

    // MARK: Initializers

    public override init(frame frameRect: NSRect) {
        Self.earlySetup(type: Self.self)
        super.init(frame: frameRect)
        Self.sharedSetup(colorWell: self)
    }

    public required init?(coder: NSCoder) {
        Self.earlySetup(type: Self.self)
        super.init(coder: coder)
        Self.sharedSetup(colorWell: self)
    }

    // MARK: Deinit

    deinit {
        // color panel holds weak references to its attached objects, so
        // detaching isn't strictly necessary, but we want to ensure the
        // immediate removal of the box that holds the reference
        NSColorPanel.shared.detach(self)
    }

    // MARK: Setup Methods

    private static func earlySetup(type: _CWColorWellBaseControl.Type) {
        // fail as early as we can here
        precondition(
            type is CWColorWell.Type,
            """
            Attempted to create instance of private class \(type). \
            Use an instance of the public \(CWColorWell.self) class instead.
            """
        )
        _ = NSColorWell.swizzler
        _ = _CWColorWellBaseControl.colorPanelObservations
    }

    private static func sharedSetup(colorWell: _CWColorWellBaseControl) {
        colorWell.addSubview(colorWell.layoutView)
    }

    // MARK: Instance Methods

    /// Updates the color well's color to the given value, using
    /// the given options.
    func updateColor(_ newColor: NSColor?, options: ColorUpdateOptions) { }

    /// Computes and returns an intrinsic content size for the
    /// given control size.
    func computeIntrinsicContentSize(for controlSize: ControlSize) -> NSSize {
        // this implementation returns the same sizes as NSColorWell
        var size = BackingStorage.defaultSize
        switch backingStorage.style {
        case .default, .minimal:
            switch controlSize {
            case .large:
                size.height += 8
            case .regular:
                break // no change
            case .small:
                size.height -= 4
            case .mini:
                size.height -= 7
            @unknown default:
                break
            }
        case .expanded:
            size.width += CWToggleSegment.widthConstant
            switch controlSize {
            case .large:
                size.width += 8
                size.height += 8
            case .regular:
                break // no change
            case .small:
                size.width -= 4
                size.height -= 4
            case .mini:
                size.width -= 7
                size.height -= 7
            @unknown default:
                break
            }
        }
        return size
    }
}

// MARK: Overridden Properties
extension _CWColorWellBaseControl {
    public override var acceptsFirstResponder: Bool { true }

    public override var alignmentRectInsets: NSEdgeInsets {
        NSEdgeInsets(top: 2, left: 3, bottom: 2, right: 3)
    }

    public override var cell: NSCell? {
        get {
            backingStorage.cell
        }
        set {
            backingStorage.cell = newValue
        }
    }

    public override var intrinsicContentSize: NSSize {
        computeIntrinsicContentSize(for: controlSize)
    }

    public override var isEnabled: Bool {
        get {
            backingStorage.isEnabled
        }
        set {
            backingStorage.isEnabled = newValue
            layoutView.setSegmentsNeedDisplay(true)
        }
    }

    public override var objectValue: Any? {
        get {
            backingStorage.color
        }
        set {
            guard let newColor = newValue as? NSColor? else {
                preconditionFailure("\(Self.self) objectValue must be a color object.")
            }
            updateColor(newColor, options: [
                .informDelegate,
                .informObservers,
            ])
        }
    }
}

// MARK: Overridden Methods
extension _CWColorWellBaseControl {
    public override func keyDown(with event: NSEvent) {
        if
            let segment = layoutView.segments.first,
            segment.validateAndPerformAction(withKeyEvent: event)
        {
            return
        }
        super.keyDown(with: event)
    }
}

// MARK: Accessibility
extension _CWColorWellBaseControl {
    public override func accessibilityChildren() -> [Any]? {
        if let toggleSegment = layoutView.segments.first(where: { $0 is CWToggleSegment }) {
            return [toggleSegment]
        }
        return []
    }

    public override func accessibilityPerformPress() -> Bool {
        // when dealing with multiple segments, the designated press action
        // should be the one that enables the finest degree of color selection;
        // the last segment just happens to be the correct one
        return layoutView.segments.last?.accessibilityPerformPress() ?? false
    }

    public override func accessibilityRole() -> NSAccessibility.Role? {
        return .colorWell
    }

    public override func accessibilityValue() -> Any? {
        return String(describing: ColorInfo(color: backingStorage.color))
    }

    public override func isAccessibilityElement() -> Bool {
        return true
    }

    public override func isAccessibilityEnabled() -> Bool {
        return isEnabled
    }
}

// MARK: - NSColorWell Swizzling

private extension NSColorWell {
    @nonobjc static let swizzler: () = {
        let originalActivateSel = #selector(activate)
        let swizzledActivateSel = #selector(cw_swizzled_activate)
        let originalDeactivateSel = #selector(deactivate)
        let swizzledDeactivateSel = #selector(cw_swizzled_deactivate)

        guard
            let originalActivateMethod = class_getInstanceMethod(NSColorWell.self, originalActivateSel),
            let swizzledActivateMethod = class_getInstanceMethod(NSColorWell.self, swizzledActivateSel),
            let originalDeactivateMethod = class_getInstanceMethod(NSColorWell.self, originalDeactivateSel),
            let swizzledDeactivateMethod = class_getInstanceMethod(NSColorWell.self, swizzledDeactivateSel)
        else {
            return
        }

        method_exchangeImplementations(originalActivateMethod, swizzledActivateMethod)
        method_exchangeImplementations(originalDeactivateMethod, swizzledDeactivateMethod)
    }()

    // MARK: Activate

    @objc private func cw_swizzled_activate(_ exclusive: Bool) {
        // important that we capture the last attached object and its color
        // BEFORE activating and attaching, so we know what color to take
        let lastAttachedObject = NSColorPanel.shared.attachedObjects.last
        let lastAttachedObjectColor: NSColor? = lastAttachedObject?.color

        if exclusive {
            NSColorPanel.shared.enforceExclusivity(of: self)
        }

        // NOTE: since this method and the original have been swizzled,
        // a call to this method is actually a call to the original
        cw_swizzled_activate(exclusive)

        // attach to match CWColorWell's behavior
        NSColorPanel.shared.attach(self)

        if NSColorPanel.shared.isExclusivelyAttached(self) {
            return
        }

        if
            let lastAttachedObjectColor,
            color != lastAttachedObjectColor
        {
            color = lastAttachedObjectColor
        }
    }

    // MARK: Deactivate

    @objc private func cw_swizzled_deactivate() {
        // NOTE: since this method and the original have been swizzled,
        // a call to this method is actually a call to the original
        cw_swizzled_deactivate()

        // detach to match CWColorWell's behavior
        NSColorPanel.shared.detach(self)
    }
}
