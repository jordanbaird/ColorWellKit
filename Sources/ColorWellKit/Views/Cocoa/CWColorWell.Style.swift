//
//  Style.swift
//  ColorWellKit
//

import Foundation

extension CWColorWell {
    /// Constants that specify the appearance and behavior of a color well.
    @objc public enum Style: Int {
        /// The color well is displayed as a rectangular control that displays
        /// the selected color and shows the system color panel when clicked.
        case `default` = 0

        /// The color well is displayed as a rectangular control that displays
        /// the selected color and shows a popover containing the color well's
        /// swatch colors when clicked.
        ///
        /// The popover contains an option to show the system color panel.
        case minimal = 1

        /// The color well is displayed as a segmented control that displays
        /// the selected color alongside a dedicated button to show the system
        /// color panel.
        ///
        /// Clicking inside the color area displays a popover containing the
        /// color well's swatch colors.
        case expanded = 2
    }
}

extension CWColorWell.Style: CustomStringConvertible {
    public var description: String {
        let prefix = String(describing: Self.self) + "."
        return switch self {
        case .default: prefix + "default"
        case .minimal: prefix + "minimal"
        case .expanded: prefix + "expanded"
        }
    }
}
