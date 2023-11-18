# ``ColorWellKit/ColorWell/Style-swift.enum/init(rawValue:)``

Creates a new color well style with the specified raw value.

If the specified raw value does not correspond to any of the existing color well styles, this initializer returns `nil`.

```swift
print(Style(rawValue: 0))
// Prints "Optional(Style.default)"

print(Style(rawValue: 1))
// Prints "Optional(Style.minimal)"

print(Style(rawValue: 2))
// Prints "Optional(Style.expanded)"

print(Style(rawValue: 3))
// Prints "nil"
```

- Parameter rawValue: The raw value to use for the new instance.
