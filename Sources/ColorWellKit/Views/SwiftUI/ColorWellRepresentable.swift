//
//  ColorWellRepresentable.swift
//  ColorWellKit
//

#if canImport(SwiftUI)
import SwiftUI

@available(macOS 10.15, *)
struct ColorWellRepresentable: NSViewRepresentable {
    final class BridgedColorWell: ColorWell {
        var mouseMonitor: LocalEventMonitor?

        var supportsOpacity: Bool = true {
            didSet {
                // remove opacity from the current color if needed
                updateColor(color, options: [])
            }
        }

        func segment(at point: NSPoint) -> ColorWellSegment? {
            layoutView.segments.first { segment in
                segment.frameConvertedToWindow.contains(point)
            }
        }

        override func updateColor(_ newColor: NSColor?, options: ColorUpdateOptions) {
            guard let newColor else {
                // the current implementation handles nil values by setting to
                // black (same as NSColorWell); call super before returning to
                // ensure consistent behavior
                super.updateColor(nil, options: options)
                return
            }
            if supportsOpacity || newColor.alphaComponent == 1 {
                // color well either supports opacity, or the new color is
                // already opaque; pass through to super
                super.updateColor(newColor, options: options)
            } else {
                let opaqueColor = newColor.withAlphaComponent(1)

                // wish we didn't need this, but it prevents some unnecessary
                // state modifications
                // TODO: Investigate...
                guard !opaqueColor.resembles(color, tolerance: 0) else {
                    return
                }

                super.updateColor(opaqueColor, options: options)
            }
        }

        override func computeIntrinsicContentSize(for controlSize: ControlSize) -> NSSize {
            var size = BackingStorage.defaultSize
            switch backingStorage.style {
            case .default:
                switch controlSize {
                case .large:
                    size.width += 17
                    size.height += 5
                case .regular:
                    size.width += 6
                case .small:
                    size.width -= 5
                    size.height -= 7
                case .mini:
                    size.width -= 9
                    size.height -= 9
                @unknown default:
                    break
                }
            case .minimal:
                switch controlSize {
                case .large:
                    size.width += 17
                    size.height += 5
                case .regular:
                    size.width += 3
                case .small:
                    size.width -= 5
                    size.height -= 7
                case .mini:
                    size.width -= 9
                    size.height -= 9
                @unknown default:
                    break
                }
            case .expanded:
                size.width += ColorWellToggleSegment.widthConstant
                switch controlSize {
                case .large:
                    size.width += 6
                    size.height += 5
                case .regular:
                    break // no change
                case .small:
                    size.width -= 8
                    size.height -= 7
                case .mini:
                    size.width -= 9
                    size.height -= 9
                @unknown default:
                    break
                }
            }
            return size
        }
    }

    final class Coordinator: ColorWellDelegate {
        let representable: ColorWellRepresentable

        init(representable: ColorWellRepresentable) {
            self.representable = representable
        }

        func colorWellDidChangeColor(_ colorWell: ColorWell) {
            representable.selection = colorWell.color
        }

        func colorWellDidActivate(_ colorWell: ColorWell) {
            if NSColorPanel.shared.isMainAttachedObject(colorWell) {
                NSColorPanel.shared.showsAlpha = representable.supportsOpacity
            }
        }
    }

    @Binding var selection: NSColor

    let supportsOpacity: Bool

    func makeNSView(context: Context) -> BridgedColorWell {
        let colorWell = BridgedColorWell(color: selection)

        colorWell.supportsOpacity = supportsOpacity
        colorWell.delegate = context.coordinator

        // certain SwiftUI views (i.e. group-styled forms) prevent the color well
        // from receiving mouse events; workaround for now is to install a local
        // event monitor and pass the event to the segment at the event's location
        let mouseMonitor = LocalEventMonitor(
            mask: [.leftMouseDown, .leftMouseUp, .leftMouseDragged]
        ) { [weak colorWell] event in
            let locationInWindow = event.locationInWindow
            guard
                let colorWell,
                colorWell.frameConvertedToWindow.contains(locationInWindow),
                let segment = colorWell.segment(at: locationInWindow)
            else {
                return event
            }
            switch event.type {
            case .leftMouseDown:
                segment.mouseDown(with: event)
                return nil
            case .leftMouseUp:
                segment.mouseUp(with: event)
                return nil
            case .leftMouseDragged:
                segment.mouseDragged(with: event)
                return nil
            default:
                return event
            }
        }

        mouseMonitor.start()
        colorWell.mouseMonitor = mouseMonitor

        return colorWell
    }

    func updateNSView(_ colorWell: BridgedColorWell, context: Context) {
        if colorWell.supportsOpacity != supportsOpacity {
            colorWell.supportsOpacity = supportsOpacity
        }
        if colorWell.color != selection {
            colorWell.color = selection
        }
        if colorWell.style != context.environment.colorWellStyleConfiguration.style {
            colorWell.style = context.environment.colorWellStyleConfiguration.style
        }
        if colorWell._popoverConfiguration != context.environment.colorWellPopoverConfiguration {
            colorWell._popoverConfiguration = context.environment.colorWellPopoverConfiguration
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(representable: self)
    }
}
#endif
