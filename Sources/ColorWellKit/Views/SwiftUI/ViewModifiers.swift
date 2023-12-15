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
    /// - Parameter action: An action to perform when the color area
    ///   of the color well is pressed.
    public func colorWellSecondaryAction(_ action: @escaping () -> Void) -> some View {
        transformEnvironment(\.colorWellSecondaryActionDelegate) { delegate in
            delegate = ColorWellSecondaryActionDelegate(action: action)
        }
    }
}
#endif
