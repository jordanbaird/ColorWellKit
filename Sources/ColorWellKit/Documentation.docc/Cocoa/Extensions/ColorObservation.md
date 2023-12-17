# Responding to Color Changes

## Overview

``CWColorWell`` provides support for several common design patterns:

### Key-value observing

To implement key-value observing, call the `observe(_:options:changeHandler:)` method with a key path to the color well's ``CWColorWell/color`` property and store the returned observation.

```swift
class MyCustomViewController: NSViewController {
    let colorWell = CWColorWell(style: .expanded)
    var observation: NSKeyValueObservation?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(colorWell)

        observation = colorWell.observe(
            \.color, 
            options: [.new]
        ) { colorWell, change in
            print("Color changed to: \(change.newValue!)")
        }
    }
}
```

For more information about key-value observing, see [Using Key-Value Observing in Swift](https://developer.apple.com/documentation/swift/using-key-value-observing-in-swift).

### Target-action

To implement the target-action mechanism, assign a target object and an action message for the target to receive when the color well's color changes.

```swift
class MyCustomViewController: NSViewController {
    let colorWell = CWColorWell(style: .expanded)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(colorWell)

        colorWell.target = self
        colorWell.action = #selector(colorDidChange(_:))
    }

    @objc func colorDidChange(_ sender: CWColorWell) {
        print("Color changed to: \(sender.color)")
    }
}
```

For more information about the target-action mechanism, see the [NSControl documentation](https://developer.apple.com/documentation/appkit/nscontrol).

### Combine publishers

> Note: The [`Combine`](https://developer.apple.com/documentation/combine) framework is available starting in macOS 10.15.

After importing `Combine`, call the `publisher(for:)` method with a key path to the color well's ``CWColorWell/color`` property. Chain the publisher to a call to `sink(receiveValue:)`, and store the returned `Cancellable` to retain the subscription.

```swift
import Combine

class MyCustomViewController: NSViewController {
    let colorWell = CWColorWell(style: .expanded)
    var cancellable: Cancellable?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(colorWell)

        cancellable = colorWell
            .publisher(for: \.color)
            .sink { color in
                print("Color changed to: \(color)")
            }
    }
}
```

For more information about using publishers, see the [Combine documentation](https://developer.apple.com/documentation/combine).
