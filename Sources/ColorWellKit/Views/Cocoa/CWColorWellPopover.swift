//
//  CWColorWellPopover.swift
//  ColorWellKit
//

import AppKit

// MARK: - CWColorWellPopover

/// A popover that contains a grid of selectable color swatches.
class CWColorWellPopover: NSPopover, NSPopoverDelegate {
    private weak var colorWell: CWColorWell?

    init(colorWell: CWColorWell) {
        self.colorWell = colorWell
        super.init()
        self.contentViewController = ContentViewController(colorWell: colorWell)
        self.behavior = .transient
        self.delegate = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func popoverDidClose(_ notification: Notification) {
        DispatchQueue.main.async { [weak colorWell] in
            colorWell?.freePopover()
        }
    }

    override func show(relativeTo positioningRect: NSRect, of positioningView: NSView, preferredEdge: NSRectEdge) {
        super.show(relativeTo: positioningRect, of: positioningView, preferredEdge: preferredEdge)
        guard
            let color = colorWell?.color,
            let contentViewController = contentViewController as? ContentViewController
        else {
            return
        }
        contentViewController.contentView.layoutView.swatchLayout.selectSwatch(matching: color)
    }
}

// MARK: - ContentViewController

extension CWColorWellPopover {
    private class ContentViewController: NSViewController {
        let contentView: ContentView

        init(colorWell: CWColorWell) {
            self.contentView = ContentView(colorWell: colorWell)
            super.init(nibName: nil, bundle: nil)
            self.view = self.contentView
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

// MARK: - ContentView

extension CWColorWellPopover {
    private class ContentView: NSView {
        let layoutView: LayoutView

        init(colorWell: CWColorWell) {
            self.layoutView = LayoutView(colorWell: colorWell)
            super.init(frame: .zero)
            addSubview(self.layoutView)
            setPadding()
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func setPadding() {
            guard layoutView.superview === self else {
                cw_log(
                    "Popover layout view is missing from its expected superview.",
                    category: .popover
                )
                return
            }

            removeConstraints(constraints)
            layoutView.removeConstraints(layoutView.constraints)

            translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                widthAnchor.constraint(equalTo: layoutView.widthAnchor, constant: 20),
                heightAnchor.constraint(equalTo: layoutView.heightAnchor, constant: 20),
            ])

            layoutView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                layoutView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
                layoutView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
                layoutView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
                layoutView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            ])
        }
    }
}

// MARK: - LayoutView

extension CWColorWellPopover {
    private class LayoutView: NSGridView {
        private weak var colorWell: CWColorWell?
        let swatchLayout: SwatchLayout

        init(colorWell: CWColorWell) {
            self.colorWell = colorWell
            self.swatchLayout = SwatchLayout(colorWell: colorWell)
            super.init(frame: .zero)
            addRow(with: [self.swatchLayout])

            if colorWell.style == .minimal {
                let activationButton = NSButton(
                    title: "Show More Colors…",
                    target: self,
                    action: #selector(activateColorWell)
                )

                activationButton.bezelStyle = .recessed
                activationButton.controlSize = .small

                addRow(with: [activationButton])
                cell(for: activationButton)?.xPlacement = .fill
            }
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        @objc private func activateColorWell() {
            colorWell?.activateAutoExclusive()
            colorWell?.freePopover()
        }
    }
}

// MARK: - SwatchLayout

extension CWColorWellPopover {
    private class SwatchLayout: NSGridView {
        private let selectionIndicator = SelectionIndicator()
        private(set) var swatches = [ColorSwatch]()

        init(colorWell: CWColorWell) {
            super.init(frame: .zero)
            self.rowSpacing = 1
            self.columnSpacing = 1
            setRows(with: colorWell)
            updateSelectionIndicator()
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        @discardableResult
        private func addSwatchRow(with swatches: [ColorSwatch]) -> NSGridRow {
            let row = addRow(with: swatches)
            self.swatches.append(contentsOf: swatches)
            return row
        }

        private func setRows(with colorWell: CWColorWell) {
            guard swatches.isEmpty else {
                cw_log("SwatchLayout rows already set", category: .popover)
                return
            }

            var currentSwatches = [ColorSwatch]()

            for color in colorWell.swatchColors {
                if currentSwatches.count >= 6 {
                    addSwatchRow(with: currentSwatches)
                    currentSwatches.removeAll()
                }
                currentSwatches.append(
                    ColorSwatch(
                        color: color,
                        size: NSSize(width: 37, height: 20),
                        colorWell: colorWell,
                        swatchLayout: self
                    )
                )
            }

            if !currentSwatches.isEmpty {
                addSwatchRow(with: currentSwatches)
            }
        }

        func selectSwatch(matching color: NSColor) {
            var matchingSwatch: ColorSwatch?

            swatchLoop:
            for swatch in swatches where swatch.color.resembles(color) {
                matchingSwatch = swatch
                switch (swatch.color.type, color.type) {
                case (.componentBased, .componentBased):
                    if swatch.color.colorSpace == color.colorSpace {
                        break swatchLoop
                    }
                case (.pattern, .pattern):
                    if swatch.color.patternImage == color.patternImage {
                        break swatchLoop
                    }
                case (.catalog, .catalog):
                    if
                        swatch.color.catalogNameComponent == color.catalogNameComponent,
                        swatch.color.colorNameComponent == color.colorNameComponent
                    {
                        break swatchLoop
                    }
                case (.componentBased, _), (.pattern, _), (.catalog, _):
                    continue swatchLoop
                @unknown default:
                    continue swatchLoop
                }
            }

            matchingSwatch?.select()
        }

        func updateSelectionIndicator() {
            guard let selectedSwatch = swatches.first(where: { $0.isSelected }) else {
                selectionIndicator.removeFromSuperview()
                return
            }
            if selectionIndicator.superview !== self {
                addSubview(selectionIndicator)
            }
            selectionIndicator.frame = selectedSwatch.frame
        }

        func swatch(at point: NSPoint) -> ColorSwatch? {
            swatches.first { swatch in
                swatch.frameConvertedToWindow.contains(point)
            }
        }

        override func mouseDragged(with event: NSEvent) {
            super.mouseDragged(with: event)
            swatch(at: event.locationInWindow)?.select()
        }

        override func mouseUp(with event: NSEvent) {
            super.mouseUp(with: event)
            guard
                let selectedSwatch = swatches.first(where: { $0.isSelected }),
                swatch(at: event.locationInWindow) === selectedSwatch
            else {
                return
            }
            selectedSwatch.performAction()
        }
    }
}

// MARK: - SelectionIndicator

extension CWColorWellPopover {
    private class SelectionIndicator: NSView {
        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            let shadow = NSShadow()
            shadow.shadowOffset = .zero
            shadow.shadowBlurRadius = 1
            shadow.shadowColor = .shadowColor.withAlphaComponent(0.5)
            self.shadow = shadow
            self.wantsLayer = true
            self.layer?.masksToBounds = false
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func draw(_ dirtyRect: NSRect) {
            NSColor.white.setStroke()
            let path = NSBezierPath(rect: bounds)
            path.lineWidth = 3
            path.lineJoinStyle = .round
            path.stroke()
        }
    }
}

// MARK: - ColorSwatch

extension CWColorWellPopover {
    private class ColorSwatch: NSView {
        private weak var colorWell: CWColorWell?
        private weak var swatchLayout: SwatchLayout?

        let color: NSColor
        private(set) var isSelected: Bool = false

        init(
            color: NSColor,
            size: NSSize,
            colorWell: CWColorWell?,
            swatchLayout: SwatchLayout?
        ) {
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

        func select() {
            guard
                !isSelected,
                let swatchLayout
            else {
                return
            }
            isSelected = true
            // unselect all other swatches
            for swatch in swatchLayout.swatches where swatch.isSelected && swatch !== self {
                swatch.isSelected = false
            }
            swatchLayout.updateSelectionIndicator()
        }

        func performAction() {
            colorWell?.updateColor(color, options: [
                .informDelegate,
                .informObservers,
                .sendAction,
            ])
            colorWell?.freePopover()
        }

        override func draw(_ dirtyRect: NSRect) {
            guard let context = NSGraphicsContext.current else {
                return
            }

            context.saveGraphicsState()
            defer {
                context.restoreGraphicsState()
            }

            context.compositingOperation = .multiply

            let color = color.usingColorSpace(.displayP3) ?? color
            color.drawSwatch(in: bounds)
            NSColor(white: 1 - color.averageBrightness, alpha: 0.3).setStroke()
            let path = NSBezierPath(rect: bounds.insetBy(dx: 1, dy: 1))
            path.lineWidth = 2
            path.stroke()
        }

        override func mouseDown(with event: NSEvent) {
            super.mouseDown(with: event)
            // this just performs the preliminary selection;
            // the action is handled by LayoutView's mouseUp
            select()
        }
    }
}
