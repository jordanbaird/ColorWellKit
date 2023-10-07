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

    /// Sets the colors of the swatches in color selection popovers displayed
    /// by color wells in this view.
    ///
    /// - Parameter colors: The colors to use to create the swatches.
    @available(macOS 11.0, *)
    public func colorWellSwatchColors(_ colors: [Color]) -> some View {
        transformEnvironment(\.colorWellPopoverConfiguration) { configuration in
            configuration.colors = colors.map { NSColor($0) }
        }
    }
}
#endif
