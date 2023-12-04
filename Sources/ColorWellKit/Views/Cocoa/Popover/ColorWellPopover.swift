//
//  ColorWellPopover.swift
//  ColorWellKit
//

import AppKit

/// A popover that contains a grid of selectable color swatches.
class ColorWellPopover: NSPopover {
    typealias Configuration = ColorWell._PopoverConfiguration

    private weak var colorWell: ColorWell?

    private let _contentViewController: ContentViewController

    var contentView: ContentView {
        _contentViewController.contentView
    }

    var swatches: [ColorSwatch] {
        contentView.swatches
    }

    init(colorWell: ColorWell, configuration: Configuration) {
        self._contentViewController = ContentViewController(
            colorWell: colorWell,
            configuration: configuration
        )
        super.init()
        self.colorWell = colorWell
        self.contentViewController = _contentViewController
        self.delegate = _contentViewController
        self.behavior = .transient
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func show(
        relativeTo positioningRect: NSRect,
        of positioningView: NSView,
        preferredEdge: NSRectEdge
    ) {
        super.show(
            relativeTo: positioningRect,
            of: positioningView,
            preferredEdge: preferredEdge
        )

        guard let color = colorWell?.color else {
            return
        }

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
}
