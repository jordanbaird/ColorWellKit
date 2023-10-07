//
//  Style.swift
//  ColorWellKit
//

import Foundation

extension ColorWell {
    /// Constants that specify the appearance and behavior of a color well.
    @objc public enum Style: Int {
        /// The color well is displayed as a rectangular control that displays
        /// the selected color and shows the system color panel when clicked.
        case standard = 0

        /// The color well is displayed as a rectangular control that displays
        /// the selected color and shows a popover containing the color well's
        /// swatch colors when clicked.
        ///
        /// The popover contains an option to show the system color panel.
        case swatches = 1

        /// The color well is displayed as a segmented control that displays
        /// the selected color alongside a dedicated button to show the system
        /// color panel.
        ///
        /// Clicking inside the color area displays a popover containing the
        /// color well's swatch colors.
        case expanded = 2
    }
}

extension ColorWell.Style: CustomStringConvertible {
    public var description: String {
        let prefix = String(describing: Self.self) + "."
        switch self {
        case .standard:
            return prefix + "standard"
        case .swatches:
            return prefix + "swatches"
        case .expanded:
            return prefix + "expanded"
        }
    }
}
