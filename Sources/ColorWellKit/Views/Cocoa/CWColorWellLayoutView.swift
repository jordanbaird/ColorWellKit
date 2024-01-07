//
//  CWColorWellLayoutView.swift
//  ColorWellKit
//

import AppKit

private protocol LayoutAnchorProtocol: Hashable { }

private extension LayoutAnchorProtocol {
    var key: LayoutAnchorKey {
        LayoutAnchorKey(self)
    }
}

private struct LayoutAnchorKey: Hashable {
    private let rawValue: Int

    init<Base: LayoutAnchorProtocol>(_ base: Base) {
        self.rawValue = base.hashValue
    }
}

extension NSLayoutAnchor: LayoutAnchorProtocol { }

/// A grid view that displays color well segments side by side.
class CWColorWellLayoutView: NSGridView {

    // MARK: Properties

    @objc dynamic // @objc dynamic to enable kvo
    private weak var colorWell: CWColorWell?

    @objc dynamic // @objc dynamic to enable kvo
    private var widthConstant: CGFloat = 0

    private var row: NSGridRow?

    private let bezelGradient: NSGradient

    private(set) var segments = [CWColorWellSegment]()

    private var styleObservation: NSKeyValueObservation?

    private var widthConstantObservation: NSKeyValueObservation?

    private var superviewConstraints = [LayoutAnchorKey: NSLayoutConstraint]() {
        didSet {
            for constraint in oldValue.values {
                constraint.isActive = false
            }
            for constraint in superviewConstraints.values {
                constraint.isActive = true
            }
        }
    }

    // MARK: Initializers

    init(colorWell: CWColorWell) {
        self.bezelGradient = NSGradient(colors: [
            NSColor.clear,
            NSColor.clear,
            NSColor.clear,
            NSColor(white: 1, alpha: 0.125),
        ])! // swiftlint:disable:this force_unwrapping
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.wantsLayer = true
        self.columnSpacing = 0
        self.xPlacement = .fill
        self.yPlacement = .fill
        self.colorWell = colorWell
        self.styleObservation = observe(\.colorWell?.style, options: .initial) { layoutView, _ in
            layoutView.update()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Methods

    /// Marks the layout view's segments as needing to be redrawn
    /// before being displayed.
    func setSegmentsNeedDisplay(_ segmentsNeedDisplay: Bool) {
        for segment in segments {
            segment.needsDisplay = segmentsNeedDisplay
        }
    }

    /// Resets the layout view to a default state.
    func resetLayoutView() {
        defer {
            assert(segments.isEmpty, "segments should be empty after layout view reset.")
            assert(numberOfRows == 0, "numberOfRows should be 0 after layout view reset.")
        }
        while let segment = segments.popLast() {
            segment.removeFromSuperview()
        }
        if let row {
            removeRow(at: index(of: row))
        }
        row = nil
    }

    /// Updates the properties of the layout view's shadow according
    /// to the color well's current style.
    func updateShadowProperties() {
        guard
            let colorWell,
            let layer
        else {
            return
        }
        switch colorWell.style {
        case .default:
            layer.shadowRadius = 0.5
            layer.shadowOpacity = 0.3
            layer.shadowOffset = NSSize(width: 0, height: -0.25)
        case .minimal:
            layer.shadowRadius = 0
            layer.shadowOpacity = 0
            layer.shadowOffset = NSSize(width: 0, height: 0)
        case .expanded:
            layer.shadowRadius = 0.4
            layer.shadowOpacity = 0.3
            layer.shadowOffset = NSSize(width: 0, height: -0.2)
        }
    }

    /// Updates the layout view according to the color well's
    /// current style.
    func update() {
        guard let colorWell else {
            return
        }
        resetLayoutView()
        switch colorWell.style {
        case .default:
            segments.append(CWBorderedSwatchSegment(colorWell: colorWell))
            widthConstant = 0
        case .minimal:
            segments.append(CWSinglePullDownSwatchSegment(colorWell: colorWell))
            widthConstant = 0
        case .expanded:
            segments.append(CWPartialPullDownSwatchSegment(colorWell: colorWell))
            segments.append(CWToggleSegment(colorWell: colorWell))
            widthConstant = -1
        }
        row = addRow(with: segments)
        updateShadowProperties()
    }

    /// Draws a bezel for the layout view in the given rectangle.
    func drawBezel() {
        guard let colorWell else {
            return
        }

        let lineWidth = 0.75
        let bezelPath: NSBezierPath

        switch colorWell.style {
        case .expanded:
            let widthConstant = CWToggleSegment.widthConstant
            bezelPath = Path.segmentPath(
                rect: NSRect(
                    x: bounds.maxX - widthConstant,
                    y: bounds.minY + lineWidth / 2,
                    width: widthConstant - lineWidth / 2,
                    height: bounds.height - lineWidth
                ),
                controlSize: colorWell.controlSize,
                segmentType: CWToggleSegment.self,
                shouldClose: false
            )
            .stroked(lineWidth: lineWidth)
            .nsBezierPath()
        case .default, .minimal:
            bezelPath = Path.fullColorWellPath(
                rect: bounds.insetBy(dx: lineWidth / 2, dy: lineWidth / 2),
                controlSize: colorWell.controlSize
            )
            .stroked(lineWidth: lineWidth)
            .nsBezierPath()
        }

        bezelGradient.draw(in: bezelPath, angle: 90)
    }

    override func viewWillDraw() {
        super.viewWillDraw()
        updateShadowProperties()
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        drawBezel()
    }

    override func viewDidMoveToSuperview() {
        if let superview {
            superviewConstraints = [
                widthAnchor.key: widthAnchor.constraint(equalTo: superview.widthAnchor),
                heightAnchor.key: heightAnchor.constraint(equalTo: superview.heightAnchor),
                leadingAnchor.key: leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                bottomAnchor.key: bottomAnchor.constraint(equalTo: superview.bottomAnchor),
            ]
        } else {
            superviewConstraints.removeAll()
        }

        widthConstantObservation = observe(
            \.widthConstant,
            options: [.initial, .new]
        ) { [weak self] _, change in
            guard
                let self,
                let newValue = change.newValue
            else {
                return
            }
            superviewConstraints[widthAnchor.key]?.constant = newValue
        }
    }
}
