//
//  ColorWellPopover+Content.swift
//  ColorWellKit
//

import AppKit

// MARK: - ContentView

extension ColorWellPopover {
    /// A view that contains a grid of selectable color swatches.
    class ContentView: NSView {

        // MARK: Properties

        private let layoutView: LayoutView

        var swatches: [ColorSwatch] {
            layoutView.swatches
        }

        // MARK: Initializers

        init(colorWell: ColorWell, configuration: Configuration) {
            self.layoutView = LayoutView(colorWell: colorWell, configuration: configuration)
            super.init(frame: .zero)
            addSubview(layoutView)
            layoutView.assignContentViewIfAble(self)
            setPadding(colorWell: colorWell, configuration: configuration)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func setPadding(colorWell: ColorWell, configuration: Configuration) {
            guard layoutView.superview === self else {
                cwk_log(
                    "Popover layout view is missing from its expected superview.",
                    category: .popover
                )
                return
            }

            let fallbackPadding: CGFloat = 6.5

            let padding = with(colorWell.style) { style in
                switch style {
                case .standard, .expanded:
                    return (
                        leading: configuration.layout.padding.leading.max ?? fallbackPadding,
                        trailing: configuration.layout.padding.trailing.max ?? fallbackPadding,
                        top: configuration.layout.padding.top.max ?? fallbackPadding,
                        bottom: configuration.layout.padding.bottom.max ?? fallbackPadding
                    )
                case .swatches:
                    return (
                        leading: configuration.layout.padding.leading.min ?? fallbackPadding,
                        trailing: configuration.layout.padding.trailing.min ?? fallbackPadding,
                        top: configuration.layout.padding.top.min ?? fallbackPadding,
                        bottom: configuration.layout.padding.bottom.min ?? fallbackPadding
                    )
                }
            }

            removeConstraints(constraints)
            layoutView.removeConstraints(layoutView.constraints)

            translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                widthAnchor.constraint(
                    equalTo: layoutView.widthAnchor,
                    constant: padding.leading + padding.trailing
                ),
                heightAnchor.constraint(
                    equalTo: layoutView.heightAnchor,
                    constant: padding.top + padding.bottom
                ),
            ])

            layoutView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                layoutView.leadingAnchor.constraint(
                    equalTo: leadingAnchor,
                    constant: padding.leading
                ),
                layoutView.trailingAnchor.constraint(
                    equalTo: trailingAnchor,
                    constant: -padding.trailing
                ),
                layoutView.topAnchor.constraint(
                    equalTo: topAnchor,
                    constant: padding.top
                ),
                layoutView.bottomAnchor.constraint(
                    equalTo: bottomAnchor,
                    constant: -padding.bottom
                ),
            ])
        }

        // MARK: Accessibility

        override func accessibilityChildren() -> [Any]? {
            return [layoutView]
        }

        override func accessibilityRole() -> NSAccessibility.Role? {
            return .group
        }
    }
}

// MARK: - ContentViewController

extension ColorWellPopover {
    /// A view controller that controls a color well popover's
    /// container view.
    class ContentViewController: NSViewController {

        // MARK: Properties

        private let colorWell: ColorWell

        let contentView: ContentView

        // MARK: Initializers

        init(colorWell: ColorWell, configuration: Configuration) {
            self.colorWell = colorWell
            self.contentView = ContentView(colorWell: colorWell, configuration: configuration)
            super.init(nibName: nil, bundle: nil)
            self.view = contentView
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

// MARK: ContentViewController: NSPopoverDelegate
extension ColorWellPopover.ContentViewController: NSPopoverDelegate {
    func popoverDidClose(_ notification: Notification) {
        DispatchQueue.main.async { [weak colorWell] in
            colorWell?.freePopover()
        }
    }
}
