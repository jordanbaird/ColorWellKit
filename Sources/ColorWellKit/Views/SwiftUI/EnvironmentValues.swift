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
private struct ColorWellSecondaryActionDelegateKey: EnvironmentKey {
    static let defaultValue: ColorWellSecondaryActionDelegate? = nil
}

@available(macOS 10.15, *)
private struct ColorPanelModeConfigurationKey: EnvironmentKey {
    static var defaultValue: _ColorPanelModeConfiguration?
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

@available(macOS 10.15, *)
extension EnvironmentValues {
    var colorWellSecondaryActionDelegate: ColorWellSecondaryActionDelegate? {
        get { self[ColorWellSecondaryActionDelegateKey.self] }
        set { self[ColorWellSecondaryActionDelegateKey.self] = newValue }
    }
}

@available(macOS 10.15, *)
extension EnvironmentValues {
    var colorPanelModeConfiguration: _ColorPanelModeConfiguration? {
        get { self[ColorPanelModeConfigurationKey.self] }
        set { self[ColorPanelModeConfigurationKey.self] = newValue }
    }
}
#endif
