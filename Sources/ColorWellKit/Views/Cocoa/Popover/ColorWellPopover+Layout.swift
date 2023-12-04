//
//  ColorWellPopover+Layout.swift
//  ColorWellKit
//

import AppKit

// MARK: - LayoutView

extension ColorWellPopover {
    /// A view that provides the layout for a color well's popover.
    class LayoutView: NSGridView {

        // MARK: Properties

        private weak var colorWell: ColorWell?

        private weak var contentView: ContentView?

        private let swatchLayout: SwatchLayout

        var swatches: [ColorSwatch] {
            swatchLayout.swatches
        }

        // MARK: Initializers

        init(colorWell: ColorWell, configuration: Configuration) {
            self.colorWell = colorWell
            self.swatchLayout = SwatchLayout(colorWell: colorWell, configuration: configuration)
            super.init(frame: .zero)
            addRow(with: [swatchLayout])
            swatchLayout.assignLayoutViewIfAble(self)

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

        func assignContentViewIfAble(_ contentView: ContentView) {
            if self.contentView == nil {
                self.contentView = contentView
            }
        }

        @objc private func activateColorWell() {
            colorWell?.activateAutoExclusive()
            colorWell?.freePopover()
        }
    }
}

// MARK: - SwatchLayout

extension ColorWellPopover.LayoutView {
    /// A view that provides the layout for a popover's color swatches.
    class SwatchLayout: NSGridView {

        // swiftlint:disable:next nesting
        typealias Configuration = ColorWell._PopoverConfiguration

        // swiftlint:disable:next nesting
        typealias ColorSwatch = ColorWellPopover.ColorSwatch

        // swiftlint:disable:next nesting
        typealias PlaceholderSwatch = ColorWellPopover.PlaceholderSwatch

        // swiftlint:disable:next nesting
        typealias LayoutView = ColorWellPopover.LayoutView

        // MARK: Properties

        private(set) var swatches = [ColorSwatch]()

        private let selectionIndicator: SelectionIndicator

        private weak var layoutView: LayoutView?

        var selectedSwatch: ColorSwatch? {
            swatches.first { $0.isSelected }
        }

        // MARK: Initializers

        init(colorWell: ColorWell, configuration: Configuration) {
            self.selectionIndicator = SelectionIndicator(configuration: configuration)
            super.init(frame: .zero)
            switch configuration.contentLayout.kind {
            case .grid(_, let horizontalSpacing, let verticalSpacing, _):
                self.rowSpacing = verticalSpacing ?? 1
                self.columnSpacing = horizontalSpacing ?? 1
            }
            setRows(colorWell: colorWell, configuration: configuration)
            updateSelectionIndicator(selectedSwatch: selectedSwatch)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // MARK: Methods

        func assignLayoutViewIfAble(_ layoutView: LayoutView) {
            if self.layoutView == nil {
                self.layoutView = layoutView
            }
        }

        @discardableResult
        private func addSwatchRow(
            with swatches: [ColorSwatch],
            columnCount: Int?,
            bottomPadding: CGFloat?,
            swatchSize: NSSize,
            configuration: Configuration
        ) -> NSGridRow {
            var swatches = swatches
            let swatchCount = swatches.count
            if
                let columnCount,
                swatchCount < columnCount
            {
                for _ in 0..<(columnCount - swatchCount) {
                    let placeholder = PlaceholderSwatch(
                        size: swatchSize,
                        configuration: configuration
                    )
                    swatches.append(placeholder)
                }
            }
            let row = addRow(with: swatches)
            if let bottomPadding {
                row.bottomPadding = bottomPadding
            }
            self.swatches.append(contentsOf: swatches)
            return row
        }

        /// Sets the rows of the layout using the given color well
        /// and configuration.
        private func setRows(colorWell: ColorWell, configuration: Configuration) {
            swatches.removeAll()

            let (columnCount, topRowSpacing) = {
                switch configuration.contentLayout.kind {
                case let .grid(_, _, _, topRowSpacing):
                    return (configuration.computeColumnCount(), topRowSpacing)
                }
            }()

            let swatchSize = configuration.computeSwatchSize()
            var currentSwatches = [ColorSwatch]()
            var bottomPadding = topRowSpacing

            // add a swatch for each color, according to the computed grid info
            for color in configuration.colors {
                if currentSwatches.count >= columnCount {
                    addSwatchRow(
                        with: currentSwatches,
                        columnCount: columnCount,
                        bottomPadding: bottomPadding,
                        swatchSize: swatchSize,
                        configuration: configuration
                    )
                    bottomPadding = nil
                    currentSwatches.removeAll()
                }
                currentSwatches.append(
                    ColorSwatch(
                        color: color,
                        size: swatchSize,
                        colorWell: colorWell,
                        swatchLayout: self,
                        configuration: configuration
                    )
                )
            }

            // the last row may not have been filled all the way, so we need
            // to check it specifically
            if !currentSwatches.isEmpty {
                addSwatchRow(
                    with: currentSwatches,
                    columnCount: columnCount,
                    bottomPadding: nil,
                    swatchSize: swatchSize,
                    configuration: configuration
                )
            }
        }

        func updateSelectionIndicator(selectedSwatch: ColorSwatch?) {
            guard
                let selectedSwatch,
                swatches.contains(selectedSwatch)
            else {
                selectionIndicator.removeFromSuperview()
                return
            }
            if selectionIndicator.superview !== self {
                addSubview(selectionIndicator)
            }
            selectionIndicator.swatchShape = selectedSwatch.swatchShape
            // clamp the border width to 1...3; anything outside that
            // range looks weird
            selectionIndicator.borderWidth = selectedSwatch.borderWidth.clamped(to: 1...3)
            // make the selection indicator's frame slightly larger
            // than the selected swatch
            selectionIndicator.frame = selectedSwatch.frame.insetBy(-1)
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
                let selectedSwatch,
                swatch(at: event.locationInWindow) === selectedSwatch
            else {
                return
            }
            selectedSwatch.performAction()
        }
    }
}

// MARK: - SelectionIndicator

extension ColorWellPopover.LayoutView.SwatchLayout {
    class SelectionIndicator: NSView {

        // swiftlint:disable:next nesting
        typealias SwatchShape = ColorWell._PopoverConfiguration.SwatchShape

        fileprivate var borderWidth: CGFloat = 0 {
            didSet {
                needsDisplay = true
            }
        }

        fileprivate var swatchShape: SwatchShape {
            didSet {
                needsDisplay = true
            }
        }

        init(configuration: Configuration) {
            self.swatchShape = configuration.swatchShape
            super.init(frame: .zero)
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
            guard let context = NSGraphicsContext.current else {
                return
            }

            context.saveGraphicsState()
            defer {
                context.restoreGraphicsState()
            }

            Path(cgPath: swatchShape.selectionPath(forRect: bounds))
                .fill(with: .white)

            context.compositingOperation = .destinationOut
            Path(cgPath: swatchShape.swatchPath(forRect: bounds.insetBy(borderWidth)))
                .fill(with: .white)
        }
    }
}
