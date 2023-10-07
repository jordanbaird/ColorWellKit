//
//  ColorWellDelegate.swift
//  ColorWellKit
//

import AppKit

/// A delegate object that communicates changes to and from a ``ColorWell``.
public protocol ColorWellDelegate: AnyObject {
    /// Informs the delegate that the color well's color is about to change.
    ///
    /// You can access the color well's current color using the ``ColorWell/color``
    /// property on the `colorWell` parameter.
    ///
    /// - Parameters:
    ///   - colorWell: The color well whose color is about to change.
    ///   - newColor: The color well's new color.
    func colorWellWillChangeColor(_ colorWell: ColorWell, to newColor: NSColor)

    /// Informs the delegate that the color well's color has changed.
    ///
    /// You can access the color well's current color using the ``ColorWell/color``
    /// property on the `colorWell` parameter.
    ///
    /// - Parameter colorWell: The color well whose color has changed.
    func colorWellDidChangeColor(_ colorWell: ColorWell)

    /// Informs the delegate that the color well has been activated.
    ///
    /// - Parameter colorWell: The activated color well.
    func colorWellDidActivate(_ colorWell: ColorWell)

    /// Informs the delegate that the color well has been deactivated.
    ///
    /// - Parameter colorWell: The deactivated color well.
    func colorWellDidDeactivate(_ colorWell: ColorWell)
}

// MARK: Default Implementations
extension ColorWellDelegate {
    public func colorWellWillChangeColor(_ colorWell: ColorWell, to newColor: NSColor) { }

    public func colorWellDidChangeColor(_ colorWell: ColorWell) { }

    public func colorWellDidActivate(_ colorWell: ColorWell) { }

    public func colorWellDidDeactivate(_ colorWell: ColorWell) { }
}
