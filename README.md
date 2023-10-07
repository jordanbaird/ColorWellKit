# ColorWellKit

[![Continuous Integration][ci-badge]](https://github.com/jordanbaird/ColorWellKit/actions/workflows/test.yml)
[![Release][release-badge]](https://github.com/jordanbaird/ColorWellKit/releases/latest)
[![License][license-badge]](LICENSE)

A versatile alternative to `NSColorWell` for Cocoa and `ColorPicker` for SwiftUI.

<div align="center">
    <img src="Sources/ColorWellKit/Documentation.docc/Resources/color-well-with-popover-dark.png" style="width:37%">
    <img src="Sources/ColorWellKit/Documentation.docc/Resources/color-well-with-popover-light.png" style="width:37%">
</div>

ColorWellKit is designed to mimic the appearance and behavior of the color well designs introduced in macOS 13 Ventura, ideal for use in apps that are unable to target the latest SDK. While a central goal of ColorWellKit is to maintain a similar look and behave in a similar way to Apple's design, it is not intended to be an exact clone. There are a number of subtle design differences ranging from the way system colors are handled to the size of the drop shadow. However, in practice, there are very few notable differences:

<div align="center">
    <img src="Sources/ColorWellKit/Documentation.docc/Resources/design-comparison-dark.png" style="width:49%">
    <img src="Sources/ColorWellKit/Documentation.docc/Resources/design-comparison-light.png" style="width:49%">
</div>

## Install

Add the following dependency to your `Package.swift` file:

```swift
.package(url: "https://github.com/jordanbaird/ColorWellKit", from: "0.1.0")
```

## Usage

### SwiftUI

Create a `ColorWellView` and add it to your view hierarchy. There are a wide range of initializers and modifiers to choose from, allowing you to set the color well's color, label, and style.

```swift
import SwiftUI
import ColorWellKit

struct ContentView: View {
    @Binding var fontColor: Color

    var body: some View {
        VStack {
            ColorWellView("Font Color", selection: $fontColor)
                .colorWellStyle(.expanded)

            MyCustomTextEditor(fontColor: fontColor)
        }
    }
}
```

### Cocoa

Create a `ColorWell` using one of the available initializers. Respond to color changes using your preferred design pattern.

```swift
import Cocoa
import ColorWellKit

class ContentViewController: NSViewController {
    @IBOutlet var textControls: NSStackView!
    @IBOutlet var textEditor: MyCustomNSTextEditor!

    private var colorObservation: NSKeyValueObservation?

    override func viewDidLoad() {
        let colorWell = ColorWell(style: .expanded)
        colorWell.color = textEditor.fontColor

        colorObservation = colorWell.observe(\.color) { colorWell, _ in
            textEditor.fontColor = colorWell.color
        }

        textControls.addArrangedSubview(colorWell)
    }
}
```

## License

ColorWellKit is available under the [MIT license](LICENSE).

[ci-badge]: https://img.shields.io/github/actions/workflow/status/jordanbaird/ColorWellKit/test.yml?branch=main&style=flat-square
[release-badge]: https://img.shields.io/github/v/release/jordanbaird/ColorWellKit?style=flat-square
[license-badge]: https://img.shields.io/github/license/jordanbaird/ColorWellKit?style=flat-square
