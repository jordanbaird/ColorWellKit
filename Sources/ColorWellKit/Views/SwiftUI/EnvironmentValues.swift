//
//  EnvironmentValues.swift
//  ColorWellKit
//

#if canImport(SwiftUI)
import SwiftUI

@available(macOS 10.15, *)
private struct ColorWellStyleConfigurationKey: EnvironmentKey {
    static let defaultValue = _ColorWellStyleConfiguration.default
}

@available(macOS 10.15, *)
private struct ColorWellPopoverConfigurationKey: EnvironmentKey {
    static let defaultValue = ColorWell._PopoverConfiguration.default
}

@available(macOS 10.15, *)
extension EnvironmentValues {
    var colorWellStyleConfiguration: _ColorWellStyleConfiguration {
        get { self[ColorWellStyleConfigurationKey.self] }
        set { self[ColorWellStyleConfigurationKey.self] = newValue }
    }
}

@available(macOS 10.15, *)
extension EnvironmentValues {
    var colorWellPopoverConfiguration: ColorWell._PopoverConfiguration {
        get { self[ColorWellPopoverConfigurationKey.self] }
        set { self[ColorWellPopoverConfigurationKey.self] = newValue }
    }
}
#endif
