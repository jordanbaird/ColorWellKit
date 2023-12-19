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
    /// Color selection popovers are displayed by color wells that use
    /// the ``ColorWellStyle/expanded`` and ``ColorWellStyle/minimal``
    /// styles. This modifier allows you to provide an array of custom
    /// colors to display in place of the default colors.
    ///
    /// ```swift
    /// ColorWell(selection: $color)
    ///     .colorWellSwatchColors([
    ///         .red, .orange, .yellow, .green, .blue, .indigo,
    ///         .purple, .brown, .gray, .white, .black,
    ///     ])
    ///     .colorWellStyle(.expanded)
    /// ```
    ///
    /// ![Custom swatch colors](custom-swatch-colors)
    ///
    /// - Parameter colors: An array of colors to use to create the
    ///   swatches.
    @available(macOS 11.0, *)
    public func colorWellSwatchColors(_ colors: [Color]) -> some View {
        transformEnvironment(\.colorWellSwatchColors) { swatchColors in
            swatchColors = colors.map { NSColor($0) }
        }
    }

    /// Sets an action to perform when the color areas of color wells
    /// in this view are pressed.
    ///
    /// If this modifier is applied, color wells that use either the
    /// ``ColorWellStyle/expanded`` or ``ColorWellStyle/minimal``
    /// styles perform the provided action instead of displaying the
    /// color selection popover, and modifiers that alter the popover
    /// (like ``colorWellSwatchColors(_:)``) have no effect.
    ///
    /// - Parameter action: An action to perform when the color areas
    ///   of the color wells are pressed.
    public func colorWellSecondaryAction(_ action: @escaping () -> Void) -> some View {
        transformEnvironment(\.colorWellSecondaryActionDelegate) { delegate in
            delegate = ColorWellSecondaryActionDelegate(action: action)
        }
    }

    /// Sets the color panel mode for color wells in this view.
    ///
    /// When a color well that uses this modifier is activated, the
    /// system color panel switches to the color panel mode that is
    /// passed to the `mode` parameter.
    ///
    /// - Parameter mode: The color panel mode to apply to the
    ///   color wells.
    public func colorPanelMode<M: ColorPanelMode>(_ mode: M) -> some View {
        environment(\.colorPanelModeConfiguration, mode._configuration)
    }
}
#endif
