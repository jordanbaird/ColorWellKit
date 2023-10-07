//
//  ColorWellPopover+ColorSwatch.swift
//  ColorWellKit
//

import AppKit

// MARK: - ColorSwatch

extension ColorWellPopover {
    /// A clickable color swatch that is displayed inside of a color
    /// well's popover.
    ///
    /// When a swatch is clicked, the color well's color value is set
    /// to the color value of the swatch.
    class ColorSwatch: NSControl {

        // MARK: Types

        // swiftlint:disable:next nesting
        typealias SwatchShape = Configuration.SwatchShape

        // swiftlint:disable:next nesting
        typealias BorderEffect = Configuration.SwatchBorderEffect

        // MARK: Properties

        private weak var colorWell: ColorWell?

        private weak var swatchLayout: LayoutView.SwatchLayout?

        /// The shape to draw the swatch with.
        let swatchShape: SwatchShape

        /// The border effect of the swatch.
        let borderEffect: BorderEffect

        /// The swatch's color value.
        let color: NSColor

        /// A Boolean value that indicates whether the swatch is
        /// selected.
        private(set) var isSelected: Bool = false

        /// The color of the swatch, converted to a standardized
        /// format for display.
        var displayColor: NSColor {
            color.usingColorSpace(.displayP3) ?? color
        }

        /// The border width of the swatch, computed based on its size.
        var borderWidth: CGFloat {
            let minDimension = min(bounds.width, bounds.height)
            let maxDimension = max(bounds.width, bounds.height)
            let dimension = maxDimension >= minDimension * 1.5
                ? maxDimension
                : minDimension
            let lineWidth = (dimension / 10).rounded(.up)
            return min(min(lineWidth, 6), minDimension / 2)
        }

        // MARK: Initializers

        init(
            color: NSColor,
            size: NSSize,
            colorWell: ColorWell?,
            swatchLayout: LayoutView.SwatchLayout?,
            configuration: Configuration
        ) {
            self.swatchShape = configuration.swatchShape
            self.borderEffect = configuration.borderEffect
            self.color = color
            super.init(frame: .zero)
            self.colorWell = colorWell
            self.swatchLayout = swatchLayout
            self.wantsLayer = true
            self.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                widthAnchor.constraint(equalToConstant: size.width),
                heightAnchor.constraint(equalToConstant: size.height),
            ])
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // MARK: Methods

        /// Selects the swatch, drawing a selection indicator around its edges and
        /// ensuring that all other swatches in the swatch view are deselected.
        ///
        /// A swatch should only ever be deselected in response to another swatch's
        /// selection. `ColorSwatch` manages the details of this process internally,
        /// so `isSelected` should not be set to `false` anywhere outside of the
        /// class. Exposing this method as the only available "selection point" and
        /// giving `isSelected` a private setter ensures that this can't happen.
        func select() {
            guard
                isEnabled,
                !isSelected,
                let swatchLayout
            else {
                return
            }
            isSelected = true
            for swatch in swatchLayout.swatches where swatch.isSelected && swatch !== self {
                swatch.isSelected = false
            }
            swatchLayout.updateSelectionIndicator(selectedSwatch: self)
        }

        /// Performs the swatch's action.
        @discardableResult
        func performAction() -> Bool {
            guard
                isEnabled,
                let colorWell
            else {
                return false
            }
            colorWell.updateColor(color, options: [
                .informDelegate,
                .informObservers,
                .sendAction,
            ])
            colorWell.freePopover()
            return true
        }

        /// Draws a checkerboard image in the given rectangle, with the given
        /// tile colors, background color, and tile width.
        private func drawCheckerboard(
            in rect: NSRect,
            tileColors: (NSColor, NSColor),
            backgroundColor: NSColor? = nil,
            tileWidth: CGFloat? = nil
        ) {
            guard let context = NSGraphicsContext.current else {
                return
            }

            context.saveGraphicsState()
            defer {
                context.restoreGraphicsState()
            }

            // if no explicit tile width, compute for 8 tiles along the
            // smallest side of rect, (like a real checkerboard)
            let tileWidth = tileWidth ?? min(rect.width, rect.height) / 8
            let patternSize = NSSize(width: tileWidth * 2, height: tileWidth * 2) // pattern is 2x2

            // draw the pattern into an image for easy tiling
            let pattern = NSImage(
                size: patternSize,
                flipped: false
            ) { rect in
                // fill the entire image with the first color
                tileColors.0.setFill()
                rect.fill(using: .copy)

                // draw two rectangles in the top leading and bottom trailing
                // corners and fill with the second color
                Path(elements: [
                    .move(to: NSPoint(x: rect.minX, y: rect.midY)),
                    .line(to: NSPoint(x: rect.maxX, y: rect.midY)),
                    .line(to: NSPoint(x: rect.maxX, y: rect.minY)),
                    .line(to: NSPoint(x: rect.midX, y: rect.minY)),
                    .line(to: NSPoint(x: rect.midX, y: rect.maxY)),
                    .line(to: NSPoint(x: rect.minX, y: rect.maxY)),
                    .close,
                ])
                .fill(with: tileColors.1)

                return true
            }
            pattern.resizingMode = .tile

            // if we have a background color, fill the rectangle with it and
            // draw the pattern at 75% opacity; If no background color, draw
            // the pattern at 100% opacity
            let fraction: CGFloat
            if let backgroundColor {
                fraction = 0.75
                backgroundColor.setFill()
                rect.fill(using: .copy)
            } else {
                fraction = 1
            }

            pattern.draw(in: rect, from: .zero, operation: .copy, fraction: fraction)
        }

        override func draw(_ dirtyRect: NSRect) {
            guard let context = NSGraphicsContext.current else {
                return
            }

            context.saveGraphicsState()
            defer {
                context.restoreGraphicsState()
            }

            context.shouldAntialias = true

            let clippingPath = swatchShape.swatchPath(forRect: bounds)
            let borderWidth = borderWidth

            // set the clip at the start; note how the border in the defer
            // block (below) uses a computed border width, while the final
            // swatch gets clipped to display an effective border width of
            // half of what was computed; this is due to the fact that I
            // am, in technical terms, too lazy to do something better
            Path(cgPath: clippingPath).clip()

            defer {
                // draw the final border no matter what
                Path(cgPath: clippingPath)
                    .stroke(
                        with: borderEffect.borderColor(from: color),
                        lineWidth: borderWidth
                    )
            }

            guard displayColor.alphaComponent != 1 else {
                // fall back to drawing the display color as a standard swatch
                displayColor.drawSwatch(in: bounds)
                return
            }

            if displayColor.alphaComponent == 0 {
                // color is totally transparent; fill with a subtle background
                // to get the point across that this is, in fact, still a swatch
                Path(cgPath: clippingPath)
                    .fill(with: NSColor(white: 0, alpha: 0.25))

                context.saveGraphicsState()
                defer {
                    context.restoreGraphicsState()
                }

                // inset and clip so the slash doesn't cut into the border
                Path(cgPath: swatchShape.swatchPath(forRect: bounds.insetBy(borderWidth / 2))).clip()

                // draw a red slash across the frame to further indicate
                // transparency
                Path(elements: [
                    .move(to: NSPoint(x: bounds.minX, y: bounds.minY)),
                    .line(to: NSPoint(x: bounds.maxX, y: bounds.maxY)),
                ])
                .stroke(
                    with: .red.withAlphaComponent(0.8),
                    lineWidth: 1
                )
            } else {
                defer {
                    // draw another border with an opaque version of the display
                    // color, to match the border color of opaque swatches
                    Path(cgPath: clippingPath)
                        .stroke(
                            with: displayColor.withAlphaComponent(1),
                            lineWidth: borderWidth
                        )
                }

                context.saveGraphicsState()
                defer {
                    context.restoreGraphicsState()
                }

                // inset and clip to prevent edge bleed
                Path(cgPath: swatchShape.swatchPath(forRect: bounds.insetBy(borderWidth / 4))).clip()

                // draw a checkerboard background to indicate transparency
                drawCheckerboard(
                    in: bounds,
                    tileColors: (.systemGray, .white),
                    backgroundColor: .controlBackgroundColor,
                    tileWidth: 3.5
                )

                let (slice, remainder) = bounds.divided(
                    atDistance: bounds.width / 2,
                    from: .minXEdge
                )
                // draw half of the swatch with an opaque version of the
                // display color
                displayColor.withAlphaComponent(1).setFill()
                NSBezierPath(rect: slice).fill()

                // draw the other half with the real display color
                displayColor.setFill()
                NSBezierPath(rect: remainder).fill()
            }
        }

        override func mouseDown(with event: NSEvent) {
            super.mouseDown(with: event)
            guard isEnabled else {
                return
            }
            // this just performs preliminary selection; the action gets
            // performed on mouseUp, which is handled by the layout view
            select()
        }

        // MARK: Accessibility

        override func accessibilityLabel() -> String? {
            return "color swatch"
        }

        override func accessibilityPerformPress() -> Bool {
            return performAction()
        }

        override func accessibilityRole() -> NSAccessibility.Role? {
            return .button
        }

        override func isAccessibilityElement() -> Bool {
            return true
        }

        override func isAccessibilityEnabled() -> Bool {
            return isEnabled
        }

        override func isAccessibilitySelected() -> Bool {
            return isSelected
        }
    }
}

// MARK: - PlaceholderSwatch

extension ColorWellPopover {
    class PlaceholderSwatch: ColorSwatch {
        init(size: NSSize, configuration: Configuration) {
            super.init(
                color: .clear,
                size: size,
                colorWell: nil,
                swatchLayout: nil,
                configuration: configuration
            )
            self.isEnabled = false
        }

        override func draw(_ dirtyRect: NSRect) {
            // no-op
        }

        override func accessibilityLabel() -> String? {
            return nil
        }
    }
}
