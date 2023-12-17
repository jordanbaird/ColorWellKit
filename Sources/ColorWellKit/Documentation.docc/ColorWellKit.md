# ``ColorWellKit``

A versatile alternative to `NSColorWell` for Cocoa and `ColorPicker` for SwiftUI.

## Overview

ColorWellKit is designed to mimic the appearance and behavior of the color well designs introduced in macOS 13 Ventura, ideal for use in apps that are unable to target the latest SDK.

| Light mode      | Dark mode      |
| --------------- | -------------- |
| ![][light-mode] | ![][dark-mode] |

## SwiftUI

Create a ``ColorWell`` and add it to your view hierarchy. There are a wide range of initializers, as well as several modifiers to choose from, allowing you to set the color well's color, label, and style.

```swift
import SwiftUI
import ColorWellKit

struct ContentView: View {
    @Binding var fontColor: Color

    var body: some View {
        VStack {
            ColorWell("Font Color", selection: $fontColor)
                .colorWellStyle(.expanded)

            MyCustomTextEditor(fontColor: fontColor)
        }
    }
}
```

## Cocoa

Create a ``CWColorWell`` using one of the available initializers. Respond to color changes using your preferred design pattern (see <doc:ColorObservation>):

```swift
import Cocoa
import ColorWellKit

class ContentViewController: NSViewController {
    @IBOutlet var textControls: NSStackView!
    @IBOutlet var textEditor: MyCustomNSTextEditor!

    private var colorObservation: NSKeyValueObservation?

    override func viewDidLoad() {
        let colorWell = CWColorWell(style: .expanded)
        colorWell.color = textEditor.fontColor

        colorObservation = colorWell.observe(\.color) { colorWell, _ in
            textEditor.fontColor = colorWell.color
        }

        textControls.addArrangedSubview(colorWell)
    }
}
```

[light-mode]: color-well-with-popover-light.png
[dark-mode]: color-well-with-popover-dark.png
