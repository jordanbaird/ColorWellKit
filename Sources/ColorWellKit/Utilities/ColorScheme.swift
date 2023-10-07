//
//  ColorScheme.swift
//  ColorWellKit
//

import AppKit

/// A value corresponding to a light or dark appearance.
enum ColorScheme {
    /// A color scheme that indicates a light appearance.
    case light
    /// A color scheme that indicates a dark appearance.
    case dark

    /// The names of the light appearances used by the system.
    private static let systemLightAppearanceNames: Set<NSAppearance.Name> = {
        var result: Set<NSAppearance.Name> = [
            .aqua,
            .vibrantLight,
        ]
        if #available(macOS 10.14, *) {
            result.formUnion([
                .accessibilityHighContrastAqua,
                .accessibilityHighContrastVibrantLight,
            ])
        }
        return result
    }()

    /// The names of the dark appearances used by the system.
    private static let systemDarkAppearanceNames: Set<NSAppearance.Name> = {
        var result: Set<NSAppearance.Name> = [
            .vibrantDark,
        ]
        if #available(macOS 10.14, *) {
            result.formUnion([
                .darkAqua,
                .accessibilityHighContrastDarkAqua,
                .accessibilityHighContrastVibrantDark,
            ])
        }
        return result
    }()

    /// Returns the color scheme that exactly matches the given appearance,
    /// or `nil` if the color scheme cannot be determined.
    private static func exactMatch(for appearance: NSAppearance) -> ColorScheme? {
        let name = appearance.name
        if systemDarkAppearanceNames.contains(name) {
            return .dark
        }
        if systemLightAppearanceNames.contains(name) {
            return .light
        }
        return nil
    }

    /// Returns the color scheme that best matches the given appearance,
    /// or `nil` if the color scheme cannot be determined.
    private static func bestMatch(for appearance: NSAppearance) -> ColorScheme? {
        let lowercased = appearance.name.rawValue.lowercased()
        if lowercased.contains("dark") {
            return .dark
        }
        if lowercased.contains("light") || lowercased.contains("aqua") {
            return .light
        }
        return nil
    }

    /// Returns the color scheme of the given appearance.
    ///
    /// If a color scheme cannot be found that matches the given appearance,
    /// the `light` color scheme is returned.
    private static func colorScheme(for appearance: NSAppearance) -> ColorScheme {
        if let match = exactMatch(for: appearance) {
            return match
        }
        if let match = bestMatch(for: appearance) {
            return match
        }
        return .light
    }

    // MARK: ColorScheme.current

    /// Returns the color scheme of the current appearance.
    ///
    /// If a color scheme cannot be found that matches the given appearance,
    /// the `light` color scheme is returned.
    static var current: ColorScheme {
        if #available(macOS 11.0, *) {
            return colorScheme(for: .currentDrawing())
        } else {
            return colorScheme(for: .current)
        }
    }
}
