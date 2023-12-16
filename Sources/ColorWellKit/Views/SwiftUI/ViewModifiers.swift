//
//  ViewModifiers.swift
//  ColorWellKit
//

#if canImport(SwiftUI)
import SwiftUI

@available(macOS 10.15, *)
extension View {
    /// Sets the style for color wells in this view.
    ///
    /// - Parameter style: The style to apply to the color wells.
    public func colorWellStyle<S: ColorWellStyle>(_ style: S) -> some View {
        environment(\.colorWellStyleConfiguration, style._configuration)
    }

    /// Sets the colors of the swatches in color selection popovers
    /// displayed by color wells in this view.
    ///
    /// - Note: If the ``colorWellSecondaryAction(_:)`` modifier is
    ///   also applied, the color wells in this view perform the provided
    ///   action instead, and this modifier has no effect.
    ///
    /// - Parameter colors: The colors to use to create the swatches.
    @available(macOS 11.0, *)
    public func colorWellSwatchColors(_ colors: [Color]) -> some View {
        transformEnvironment(\.colorWellSwatchColors) { swatchColors in
            swatchColors = colors.map { NSColor($0) }
        }
    }

    /// Sets an action to perform when the color areas of color wells
    /// in this view are pressed.
    ///
    /// - Note: If this modifier is applied, the color wells in this
    ///   view perform the provided action instead of displaying the
    ///   default color selection popover. As such, modifiers that alter
    ///   the default popover (such as ``colorWellSwatchColors(_:)``)
    ///   do not take effect if this modifier is also applied.
    ///
    /// - Parameter action: An action to perform when the color areas
    ///   of color wells in this view are pressed.
    public func colorWellSecondaryAction(_ action: @escaping () -> Void) -> some View {
        transformEnvironment(\.colorWellSecondaryActionDelegate) { delegate in
            delegate = ColorWellSecondaryActionDelegate(action: action)
        }
    }
}
#endif
