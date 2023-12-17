//
//  Extensions.swift
//  ColorWellKit
//

import AppKit
#if canImport(SwiftUI)
import SwiftUI
#endif

// MARK: CGRect
extension CGRect {
    /// Returns a new rectangle that is the result of centering the current
    /// rectangle within the bounds of another rectangle.
    func centered(in other: CGRect) -> CGRect {
        var copy = self
        copy.origin.x = other.midX - copy.width / 2
        copy.origin.y = other.midY - copy.height / 2
        return copy
    }

    /// Returns a rectangle that has been inset by the given dimension.
    func insetBy(_ dimension: CGFloat) -> CGRect {
        insetBy(dx: dimension, dy: dimension)
    }
}

// MARK: Comparable
extension Comparable {
    /// Returns a value that is the result of clamping the current value to
    /// the given limiting range.
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}

// MARK: NSColor
extension NSColor {
    /// Returns the average of this color's red, green, and blue components,
    /// approximating the brightness of the color.
    var averageBrightness: CGFloat {
        guard let rgb = usingColorSpace(.displayP3) else {
            return 0
        }
        return (rgb.redComponent + rgb.greenComponent + rgb.blueComponent) / 3
    }

    /// Creates a color from a hexadecimal string.
    convenience init?(hexString: String) {
        func takeFirstComponent(from iterator: inout String.Iterator) -> CGFloat? {
            // assume 6 or 8 char (RRGGBB[AA]) strings (and ignore the 3 and 4 char
            // (RGB[A]) variants); try to eat the next 2 characters; if either call
            // to `next()` returns `nil`, the full component cannot be returned
            guard
                let c1 = iterator.next(),
                let c2 = iterator.next(),
                let component = Int(String([c1, c2]), radix: 16)
            else {
                return nil
            }
            return CGFloat(component) / 255
        }

        var iterator = hexString.trimmingCharacters(in: ["#"]).makeIterator()

        guard
            let r = takeFirstComponent(from: &iterator),
            let g = takeFirstComponent(from: &iterator),
            let b = takeFirstComponent(from: &iterator)
        else {
            return nil
        }
        let a = takeFirstComponent(from: &iterator) ?? 1

        self.init(srgbRed: r, green: g, blue: b, alpha: a)
    }

    /// Creates a new color object whose component values are a weighted sum
    /// of the current and specified color objects.
    ///
    /// This method converts both colors to RGB before blending. If either
    /// color is unable to be converted, this method returns the current color
    /// unaltered.
    ///
    /// - Parameters:
    ///   - fraction: The amount of `color` to blend with the current color.
    ///   - color: The color to blend with the current color.
    ///
    /// - Returns: The blended color, if successful. If either color is unable
    ///   to be converted, the current color is returned unaltered.
    func blending(fraction: CGFloat, of color: NSColor) -> NSColor {
        guard
            let color1 = usingColorSpace(.genericRGB),
            let color2 = color.usingColorSpace(.genericRGB)
        else {
            return self
        }

        var (r1, g1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        var (r2, g2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)

        color1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        let clampedFraction = fraction.clamped(to: 0...1)
        let inverseFraction = 1 - clampedFraction

        let r = (r1 * inverseFraction).addingProduct(r2, clampedFraction)
        let g = (g1 * inverseFraction).addingProduct(g2, clampedFraction)
        let b = (b1 * inverseFraction).addingProduct(b2, clampedFraction)
        let a = (a1 * inverseFraction).addingProduct(a2, clampedFraction)

        return NSColor(calibratedRed: r, green: g, blue: b, alpha: a)
    }

    /// Returns a Boolean value that indicates whether this color resembles
    /// the given color, using the specified tolerance.
    ///
    /// This method checks within the typical, non-grayscale color spaces.
    ///
    /// - Parameters:
    ///   - other: A color to compare this color to.
    ///   - tolerance: The maximum allowed difference per color component.
    func resembles(_ other: NSColor, tolerance: CGFloat = 0.0001) -> Bool {
        func resembles(using colorSpace: NSColorSpace) -> Bool {
            guard
                let first = usingColorSpace(colorSpace),
                let second = other.usingColorSpace(colorSpace)
            else {
                // one or both can't be converted
                return false
            }

            if first == second {
                // converted colors are equal
                return true
            }

            let (firstCount, secondCount) = (
                first.numberOfComponents,
                second.numberOfComponents
            )

            guard firstCount == secondCount else {
                // this shouldn't happen, as both colors have the same
                // color space, but check just in case
                return false
            }

            var components1 = [CGFloat](repeating: 0, count: firstCount)
            var components2 = [CGFloat](repeating: 0, count: secondCount)

            first.getComponents(&components1)
            second.getComponents(&components2)

            // if the difference between each component is within the
            // specified tolerance, return true
            return (0..<firstCount).allSatisfy { index in
                abs(components1[index] - components2[index]) <= tolerance
            }
        }

        if self == other {
            // colors are equal, no conversion needed
            return true
        }

        // check between each of the most common color spaces, or until
        // one of the checks comes back with `true`
        let colorSpaces: [NSColorSpace] = [
            // standard
            .displayP3,
            .sRGB,
            .extendedSRGB,
            .adobeRGB1998,

            // generic
            .genericRGB,
            .genericCMYK,

            // device
            .deviceRGB,
            .deviceCMYK,
        ]

        return colorSpaces.contains(where: resembles(using:))
    }

    /// Creates a copy of this color by passing it through an archiving and
    /// unarchiving process, returning what is effectively the same color, but
    /// cleared of unnecessary context.
    func createArchivedCopy() -> NSColor {
        let colorData: Data = {
            // Don't require secure coding. This is the entire reason we even
            // need this function. Certain NSColor-backed SwiftUI colors don't
            // support secure coding. Error messages point to a custom NSColor
            // subclass that SwiftUI uses behind the scenes. Its declaration
            // is internal to SwiftUI, so there isn't much we can do about it.
            //
            // An incredibly hacky solution is to archive the color where we
            // know secure coding isn't (shouldn't be?) needed, then create a
            // "pure" NSColor from the archived data. We could go the route of
            // converting the color to RGB beforehand, but that would arguably
            // be even more hacky, and would risk losing potentially important
            // color data.
            //
            // TODO: Investigate other solutions.
            let archiver = NSKeyedArchiver(requiringSecureCoding: false)

            encode(with: archiver)
            return archiver.encodedData
        }()

        guard
            let unarchiver = try? NSKeyedUnarchiver(forReadingFrom: colorData),
            let copy = NSColor(coder: unarchiver)
        else {
            // fall back to the original color if copying fails
            return self
        }

        return copy
    }
}

// MARK: NSColorPanel
extension NSColorPanel {
    /// Box for a weak reference to an attached object.
    private class WeakObject {
        private(set) weak var object: AnyObject?

        init(object: AnyObject) {
            self.object = object
        }
    }

    /// Storage for the weak references to the color panel's attached objects.
    private static let weakObjectStorage = ObjectAssociation<[WeakObject]>()

    /// The objects that are currently attached to the color panel.
    var attachedObjects: [AnyObject] {
        get {
            Self.weakObjectStorage[self]?.compactMap { $0.object } ?? []
        }
        set {
            Self.weakObjectStorage[self] = newValue.map { WeakObject(object: $0) }
            guard !newValue.isEmpty else {
                return
            }
            if let color: NSColor = newValue[0].color {
                self.color = color
            }
            for case let colorWell as CWColorWell in newValue[1...] {
                colorWell.updateColor(color, options: [
                    .informDelegate,
                    .informObservers,
                    .sendAction,
                ])
            }
        }
    }

    /// Returns a Boolean value indicating whether the color panel's list of
    /// attached objects contains the specified object.
    func isAttached(_ object: AnyObject) -> Bool {
        attachedObjects.contains { $0 === object }
    }

    /// Returns a Boolean value indicating whether the given object is
    /// exclusively attached.
    func isExclusivelyAttached(_ object: AnyObject) -> Bool {
        attachedObjects.first === object &&
        attachedObjects.count == 1
    }

    /// Returns a Boolean value indicating whether the given object is the
    /// main attached object, that is, the most recently attached object.
    ///
    /// The main attached object controls the color of the color panel.
    func isMainAttachedObject(_ object: AnyObject) -> Bool {
        attachedObjects.first === object
    }

    /// Adds the specified object to the color panel's list of attached objects.
    func attach(_ object: AnyObject) {
        guard !isAttached(object) else {
            return
        }
        attachedObjects.append(object)
    }

    /// Removes the specified object from the color panel's list of attached
    /// objects.
    func detach(_ object: AnyObject) {
        attachedObjects.removeAll { $0 === object }
    }

    /// Enforces the exclusivity of an object by detaching all other attached
    /// objects.
    ///
    /// If an attached object defines a `deactivate()` method, the object will
    /// be deactivated instead of detached. An assertion failure occurs in debug
    /// builds if the object is not manually detached during deactivation.
    func enforceExclusivity(of exclusiveObject: AnyObject) {
        for object in attachedObjects where object !== exclusiveObject {
            if let deactivate = object.deactivate {
                deactivate()
                assert(!isAttached(object), "Object not detached during deactivation.")
            } else {
                detach(object)
            }
        }
    }
}

// MARK: NSImage
extension NSImage {
    /// Returns a new image by tinting the current image with the given color.
    ///
    /// - Parameters:
    ///   - color: The color to tint the image to.
    ///   - fraction: The amount of `color` to blend into the image.
    func tinted(to color: NSColor, fraction: CGFloat) -> NSImage {
        if fraction <= 0 {
            return self
        }

        let overlay = NSImage(size: size, flipped: false) { bounds in
            guard
                let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil),
                let context = NSGraphicsContext.current
            else {
                return false
            }
            color.setFill()
            context.cgContext.clip(to: bounds, mask: cgImage)
            context.cgContext.fill(bounds)
            return true
        }

        return NSImage(size: size, flipped: false) { bounds in
            self.draw(in: bounds)
            overlay.draw(in: bounds, from: .zero, operation: .sourceAtop, fraction: fraction)
            return true
        }
    }

    /// Returns an image by redrawing the current image with the given opacity.
    ///
    /// - Parameter opacity: The opacity of the returned image.
    func opacity(_ opacity: CGFloat) -> NSImage {
        if opacity >= 1 {
            return self
        }
        return NSImage(size: size, flipped: false) { bounds in
            self.draw(in: bounds, from: bounds, operation: .copy, fraction: opacity)
            return true
        }
    }
}

// MARK: NSView
extension NSView {
    /// Returns this view's frame, converted to the coordinate system of
    /// its window.
    var frameConvertedToWindow: NSRect {
        superview?.convert(frame, to: nil) ?? frame
    }
}

// MARK: - SwiftUI Extensions -

#if canImport(SwiftUI)

// MARK: Binding where Value == CGColor
@available(macOS 10.15, *)
extension Binding where Value == CGColor {
    /// A binding to an `NSColor` derived from this binding.
    var nsColor: Binding<NSColor> {
        Binding<NSColor>(
            get: { NSColor(cgColor: wrappedValue) ?? .black },
            set: { wrappedValue = $0.cgColor }
        )
    }
}

// MARK: Binding where Value == Color
@available(macOS 11.0, *)
extension Binding where Value == Color {
    /// A binding to an `NSColor` derived from this binding.
    var nsColor: Binding<NSColor> {
        Binding<NSColor>(
            get: { NSColor(wrappedValue) },
            set: { wrappedValue = Color($0) }
        )
    }
}
#endif
