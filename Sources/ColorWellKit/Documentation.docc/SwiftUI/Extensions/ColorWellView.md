# ``ColorWellKit/ColorWellView``

Color wells provide an interface in your app for users to select custom colors. A color well displays the currently selected color, and provides options for selecting new colors. There are a number of styles to choose from, letting you customize the color well's appearance and behavior.

By default, color wells support colors with opacity. To disable opacity support, set the `supportsOpacity` parameter to `false`. In this mode, the color well won't show controls for adjusting the opacity of the selected color, and removes opacity from colors set programmatically or selected using another method, like drag-and-drop.

You create a color well by providing a title string and a `Binding` to a `Color`:

```swift
struct TextFormatter: View {
    @Binding var fgColor: Color
    @Binding var bgColor: Color

    var body: some View {
        HStack {
            ColorWellView("Foreground", selection: $fgColor)
            ColorWellView("Background", selection: $bgColor)
        }
    }
}
```

![Two color wells, both displayed in the default style](default-style)

### Styling color wells

You can customize a color well's appearance using one of the available color well styles, like ``ColorWellStyle/expanded``, and apply the style with the ``colorWellStyle(_:)`` modifier:

```swift
HStack {
    ColorWellView("Foreground", selection: $fgColor)
    ColorWellView("Background", selection: $bgColor)
}
.colorWellStyle(.expanded)
```

If you apply the style to a container view, as in the example above, all the color wells in the container use the style:

![Two color wells, both displayed in the expanded style](expanded-style)

## Topics

### Creating a color well

- ``init(selection:supportsOpacity:)-49a1c``
- ``init(selection:supportsOpacity:label:)-1nrle``
- ``init(_:selection:supportsOpacity:)-94x5b``
- ``init(_:selection:supportsOpacity:)-23d0k``

### Creating a Core Graphics color well

- ``init(selection:supportsOpacity:)-fckw``
- ``init(selection:supportsOpacity:label:)-5x6i1``
- ``init(_:selection:supportsOpacity:)-36cvh``
- ``init(_:selection:supportsOpacity:)-5i525``

### Modifying color wells

- ``colorWellStyle(_:)``
- ``colorWellSwatchColors(_:)``

### Getting a color well's content view

- ``body``

### Supporting Types

- ``ColorWellStyle``
