# ``ColorWellKit/ColorWell``

## Overview

Color wells provide an interface in your app for users to select custom colors. A color well displays the currently selected color, and provides options for selecting new colors. There are a number of styles to choose from, letting you customize the color well's appearance and behavior. You can also observe the color well's color and execute custom code when the color changes (see <doc:ColorObservation>).

## Topics

### Creating a color well

- ``init(style:)``
- ``init(color:)``

### Configuring the color well

- ``allowsMultipleSelection``
- ``delegate``
- ``popoverConfiguration-swift.property``
- ``secondaryAction``
- ``secondaryTarget``
- ``style-swift.property``

### Accessing the current color

- ``color``
- <doc:ColorObservation>

### Color well activation

- ``isActive``
- ``activate(exclusive:)``
- ``deactivate()``

### Supporting Types

- ``ColorWellDelegate``
- ``PopoverConfiguration-swift.struct``
- ``Style-swift.enum``
