//
//  ColorWell.swift
//  ColorWellKit
//

#if canImport(SwiftUI)
import SwiftUI

/// A view that displays a user-selectable color value.
@available(macOS 10.15, *)
public struct ColorWell<Label: View>: View {
    @Binding private var selection: NSColor

    private let supportsOpacity: Bool

    private let label: Label?

    private var representable: some View {
        ColorWellRepresentable(selection: $selection, supportsOpacity: supportsOpacity)
            .alignmentGuide(.firstTextBaseline) { context in
                context[VerticalAlignment.center]
            }
            .fixedSize()
    }

    private var alignedLabel: (some View)? {
        label?.alignmentGuide(.firstTextBaseline) { context in
            context[VerticalAlignment.center]
        }
    }

    /// The content view of the color well.
    public var body: some View {
        if let alignedLabel {
            if #available(macOS 13.0, *) {
                LabeledContent(
                    content: { representable },
                    label: { alignedLabel }
                )
            } else {
                Backports.LabeledContent(
                    content: { representable },
                    label: { alignedLabel }
                )
            }
        } else {
            representable
        }
    }

    /// A base initializer for others to delegate to.
    private init(selection: Binding<NSColor>, supportsOpacity: Bool, label: Label?) {
        self._selection = selection
        self.supportsOpacity = supportsOpacity
        self.label = label
    }
}

// MARK: ColorWell where Label: View
@available(macOS 10.15, *)
extension ColorWell {
    /// Creates a color well with a binding to a color value, with the provided
    /// view being used as the color well's label.
    ///
    /// - Parameters:
    ///   - selection: A binding to the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether the color well
    ///     allows adjusting the selected color's opacity; the default is `true`.
    ///   - label: A view that describes the purpose of the color well.
    @available(macOS 11.0, *)
    public init(
        selection: Binding<Color>,
        supportsOpacity: Bool = true,
        @ViewBuilder label: () -> Label
    ) {
        self.init(
            selection: selection.nsColor,
            supportsOpacity: supportsOpacity,
            label: label()
        )
    }

    /// Creates a color well with a binding to a color value, with the provided
    /// view being used as the color well's label.
    ///
    /// - Parameters:
    ///   - selection: A binding to the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether the color well
    ///     allows adjusting the selected color's opacity; the default is `true`.
    ///   - label: A view that describes the purpose of the color well.
    public init(
        selection: Binding<CGColor>,
        supportsOpacity: Bool = true,
        @ViewBuilder label: () -> Label
    ) {
        self.init(
            selection: selection.nsColor,
            supportsOpacity: supportsOpacity,
            label: label()
        )
    }
}

// MARK: ColorWell where Label == Never
@available(macOS 10.15, *)
extension ColorWell where Label == Never {
    /// Creates a color well with a binding to a color value.
    ///
    /// - Parameters:
    ///   - selection: A binding to the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether the color well
    ///     allows adjusting the selected color's opacity; the default is `true`.
    @available(macOS 11.0, *)
    public init(selection: Binding<Color>, supportsOpacity: Bool = true) {
        self.init(
            selection: selection.nsColor,
            supportsOpacity: supportsOpacity,
            label: nil
        )
    }

    /// Creates a color well with a binding to a color value.
    ///
    /// - Parameters:
    ///   - selection: A binding to the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether the color well
    ///     allows adjusting the selected color's opacity; the default is `true`.
    public init(selection: Binding<CGColor>, supportsOpacity: Bool = true) {
        self.init(
            selection: selection.nsColor,
            supportsOpacity: supportsOpacity,
            label: nil
        )
    }
}

// MARK: ColorWell where Label == Text
@available(macOS 10.15, *)
extension ColorWell where Label == Text {

    // MARK: Generate Label From StringProtocol

    /// Creates a color well with a binding to a color value, that generates its
    /// label from a string.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the color well.
    ///   - selection: A binding to the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether the color well
    ///     allows adjusting the selected color's opacity; the default is `true`.
    @available(macOS 11.0, *)
    public init<S: StringProtocol>(
        _ title: S,
        selection: Binding<Color>,
        supportsOpacity: Bool = true
    ) {
        self.init(
            selection: selection.nsColor,
            supportsOpacity: supportsOpacity,
            label: Text(title)
        )
    }

    /// Creates a color well with a binding to a color value, that generates its
    /// label from a string.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the color well.
    ///   - selection: A binding to the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether the color well
    ///     allows adjusting the selected color's opacity; the default is `true`.
    public init<S: StringProtocol>(
        _ title: S,
        selection: Binding<CGColor>,
        supportsOpacity: Bool = true
    ) {
        self.init(
            selection: selection.nsColor,
            supportsOpacity: supportsOpacity,
            label: Text(title)
        )
    }

    // MARK: Generate Label From LocalizedStringKey

    /// Creates a color well with a binding to a color value, that generates its
    /// label from a localized string key.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the localized title of the color well.
    ///   - selection: A binding to the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether the color well
    ///     allows adjusting the selected color's opacity; the default is `true`.
    @available(macOS 11.0, *)
    public init(
        _ titleKey: LocalizedStringKey,
        selection: Binding<Color>,
        supportsOpacity: Bool = true
    ) {
        self.init(
            selection: selection.nsColor,
            supportsOpacity: supportsOpacity,
            label: Text(titleKey)
        )
    }

    /// Creates a color well with a binding to a color value, that generates its
    /// label from a localized string key.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the localized title of the color well.
    ///   - selection: A binding to the color well's color.
    ///   - supportsOpacity: A Boolean value that indicates whether the color well
    ///     allows adjusting the selected color's opacity; the default is `true`.
    public init(
        _ titleKey: LocalizedStringKey,
        selection: Binding<CGColor>,
        supportsOpacity: Bool = true
    ) {
        self.init(
            selection: selection.nsColor,
            supportsOpacity: supportsOpacity,
            label: Text(titleKey)
        )
    }
}
#endif
