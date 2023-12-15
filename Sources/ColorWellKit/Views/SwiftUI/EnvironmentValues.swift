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
private struct ColorWellSwatchColorsKey: EnvironmentKey {
    static let defaultValue: [NSColor]? = nil
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
    var colorWellSwatchColors: [NSColor]? {
        get { self[ColorWellSwatchColorsKey.self] }
        set { self[ColorWellSwatchColorsKey.self] = newValue }
    }
}
#endif
