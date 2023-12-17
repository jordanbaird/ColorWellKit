//
//  CWColorWellDelegate.swift
//  ColorWellKit
//

import AppKit

/// A delegate object that communicates changes to and from a ``CWColorWell``.
public protocol CWColorWellDelegate: AnyObject {
    /// Informs the delegate that the color well's color is about to change.
    ///
    /// You can access the color well's current color using the ``CWColorWell/color``
    /// property on the `colorWell` parameter.
    ///
    /// - Parameters:
    ///   - colorWell: The color well whose color is about to change.
    ///   - newColor: The color well's new color.
    func colorWellWillChangeColor(_ colorWell: CWColorWell, to newColor: NSColor)

    /// Informs the delegate that the color well's color has changed.
    ///
    /// You can access the color well's current color using the ``CWColorWell/color``
    /// property on the `colorWell` parameter.
    ///
    /// - Parameter colorWell: The color well whose color has changed.
    func colorWellDidChangeColor(_ colorWell: CWColorWell)

    /// Informs the delegate that the color well has been activated.
    ///
    /// - Parameter colorWell: The activated color well.
    func colorWellDidActivate(_ colorWell: CWColorWell)

    /// Informs the delegate that the color well has been deactivated.
    ///
    /// - Parameter colorWell: The deactivated color well.
    func colorWellDidDeactivate(_ colorWell: CWColorWell)
}

// MARK: Default Implementations
extension CWColorWellDelegate {
    public func colorWellWillChangeColor(_ colorWell: CWColorWell, to newColor: NSColor) { }

    public func colorWellDidChangeColor(_ colorWell: CWColorWell) { }

    public func colorWellDidActivate(_ colorWell: CWColorWell) { }

    public func colorWellDidDeactivate(_ colorWell: CWColorWell) { }
}
