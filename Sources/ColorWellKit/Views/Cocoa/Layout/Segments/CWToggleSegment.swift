//
//  CWToggleSegment.swift
//  ColorWellKit
//

import AppKit

// MARK: - CWToggleSegment

/// A segment that toggles the system color panel when pressed.
class CWToggleSegment: CWColorWellSegment {

    // MARK: Types

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

        static let enabledImageForDarkAppearance = defaultImage
            .tinted(to: .white, fraction: 1 / 3)

        static let enabledImageForLightAppearance = defaultImage
            .tinted(to: .black, fraction: 1 / 5)

        static let disabledImageForDarkAppearance = defaultImage
            .tinted(to: .gray, fraction: 1 / 3)
            .opacity(0.5)

        static let disabledImageForLightAppearance = defaultImage
            .tinted(to: .gray, fraction: 1 / 5)
            .opacity(0.5)
    }

    // MARK: Properties

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

    // MARK: Initializers

    override init(colorWell: CWColorWell) {
        super.init(colorWell: colorWell)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalToConstant: Self.widthConstant).isActive = true
    }

    // MARK: Methods

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

    // MARK: Accessibility

    override func accessibilityLabel() -> String? {
        return "color picker"
    }
}
