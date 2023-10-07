//
//  Backporting.swift
//  ColorWellKit
//

#if canImport(SwiftUI)
import SwiftUI

/// A namespace for backported `SwiftUI` functionality.
enum Backports { }

@available(macOS 10.15, *)
private enum ControlAlignment: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
        context[HorizontalAlignment.center]
    }
}

@available(macOS 10.15, *)
private extension HorizontalAlignment {
    static let controlAlignment = HorizontalAlignment(ControlAlignment.self)
}

@available(macOS 10.15, *)
extension Backports {
    struct LabeledContent<Label: View, Content: View>: View {
        private let label: Label
        private let content: Content

        var body: some View {
            HStack(alignment: .firstTextBaseline) {
                label
                content
                    .labelsHidden()
                    .alignmentGuide(.controlAlignment) { context in
                        context[.leading]
                    }
            }
            .alignmentGuide(.leading) { context in
                context[.controlAlignment]
            }
        }

        init(@ViewBuilder content: () -> Content, @ViewBuilder label: () -> Label) {
            self.label = label()
            self.content = content()
        }
    }
}
#endif
