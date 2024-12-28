# aseprite-scripts

This repo contains custom scripts for use in Aseprite.





<br></br>
# Installation

> [!IMPORTANT]  
> [How to locate the Aseprite scripts folder?](https://community.aseprite.org/t/locate-user-scripts-folder/2170)


1. Copy the _contents_ of the `scripts` folder to your Aseprite scripts folder.  
1. Copy the `modules` folder to your Aseprite scripts folder.
1. In Aseprite, scan the scripts folder for new scripts (`File | Scripts | Rescan Scripts Folder`).

> [!TIP]  
> When using scripts frequently it is recommended to create a shortcut key to them using `Edit | Keyboard Shortcuts`.

**v1.0.0 Installed in folder**  
<img src="assets/installed.png?v2024-12-29" alt="v1.0.0 Installed in folder">



<br></br>
# Scripts

This repo currently contains only a single script for Aseprite but more will be added over time.  Much of the functionality used by the script has been separated into modules that can be used by other scripts. See the [wiki](https://github.com/ZodmanPerth/aseprite-scripts/wiki) for additional details.

Below is an outline of the script that can be used through Aseprite.

## [Colour selected pixels](https://github.com/ZodmanPerth/aseprite-scripts/wiki/Colour-selected-pixels)

Provides a dialog for the user to set/adjust the RGBA colour channels of selected pixels on an image.  It was developed mainly as a working test of the RGBA custom widget in the [custom widget module](#custom-widgets).

### Features
* Allows single or multiple selections for modification.
* Pixels with no alpha value (transparent) can be opted in or out of the change (defaults to out).
* The value can be modified with a slider or a numeric text box.
* The dialog remembers and restores the values when toggling between absolute and relative modes.
* The result of the operation are previewed live on the image and can be cancelled.
* The accepted results are undoable/redoable.  Undo history contains a single event for the operation.
* The RGBA and operation buttons on the dialog have tooltips that explain the state of the dialog when hovering.

### Demo
<img src="assets/screenshots/colour-selected-pixels/demo.gif?v2024-12-08" width=50% alt="demo of the features of the script">




<br></br>
# Modules

To support the scripts a number of modules have been created.  These modules contain additional functionality to ensure script code can focus purely on setup and execution of script features (separation of concerns).

See the [wiki](https://github.com/ZodmanPerth/aseprite-scripts/wiki) for more information about each module.

## Setup

You must import the modules into your main script globally to use them.  Some of the modules require these modules to be configured with the exact names provided in the example.

### Example
```lua
bindingX = dofile("modules/bindingExtensions.lua")
customWidgets = dofile("modules/customWidgets.lua")
luaX = dofile("modules/luaExtensions.lua")
selectionX = dofile("modules/selectionExtensions.lua")
stringX = dofile("modules/stringExtensions.lua")
```



## [Custom Widgets](https://github.com/ZodmanPerth/aseprite-scripts/wiki/Custom-widgets-module)

Contains custom widgets that can be used on a canvas in a dialog.  Kudos for the idea goes to the Aseprite team's [Custom Widget Example](https://github.com/aseprite/Aseprite-Script-Examples/blob/main/Custom%20Widgets.lua).

### Widgets
* [Label](https://github.com/ZodmanPerth/aseprite-scripts/wiki/Custom-widgets-module#label)
* [Button](https://github.com/ZodmanPerth/aseprite-scripts/wiki/Custom-widgets-module#button) (including toggle variant)
* [RGBA](https://github.com/ZodmanPerth/aseprite-scripts/wiki/Custom-widgets-module#rgba) (and operation) button cluster
* [Tooltip](https://github.com/ZodmanPerth/aseprite-scripts/wiki/Custom-widgets-module#tooltip) (though it's not reusable outside the custom widgets provided at present)



## [Selection Extensions](https://github.com/ZodmanPerth/aseprite-scripts/wiki/Selection-extensions-module)

Provides functions for working with selections in Aseprite.

### Functions

* [Iterate Selection](https://github.com/ZodmanPerth/aseprite-scripts/wiki/Selection-extensions-module#iterateSelection)



## [Binding Extensions](https://github.com/ZodmanPerth/aseprite-scripts/wiki/Binding-extensions-module)

Provides functionality that binds widgets together so their properties automatically affect one another.

### Features

* [Dialog to Custom Widgets module](https://github.com/ZodmanPerth/aseprite-scripts/wiki/Binding-extensions-module#dialogbinding)
* [Slider to Number text box](https://github.com/ZodmanPerth/aseprite-scripts/wiki/Binding-extensions-module#slidernumberbinding)


## [String Extensions](https://github.com/ZodmanPerth/aseprite-scripts/wiki/String-extensions-module)

Provides functions for working with strings in Aseprite scripts.

### Functions

| Function                                                                                                                 | Description                                                                                                    |
| ------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------- |
| [concatWithCommas](https://github.com/ZodmanPerth/aseprite-scripts/wiki/String-extensions-module#concatwithcommas)       | Returns all the passed parameters concatenated together with "," as a separator                                |
| [concatWithSeparator](https://github.com/ZodmanPerth/aseprite-scripts/wiki/String-extensions-module#concatwithseparator) | Returns all the passed parameters concatenated together with the first parameter as a separator                |
| [dumpTable](https://github.com/ZodmanPerth/aseprite-scripts/wiki/String-extensions-module#dumptable)                     | Returns the passed table as a multiline and indented string suitable for printing                              |
| [dumpColourRGBA](https://github.com/ZodmanPerth/aseprite-scripts/wiki/String-extensions-module#dumpColourRGBA)           | Returns a string representing the red, greed, blue, and alpha channels of the passed Colour                    |
| [dumpColourRGBATable](https://github.com/ZodmanPerth/aseprite-scripts/wiki/String-extensions-module#dumpColourRGBATable) | Returns a table containing the RGBA channels and the passed Color as properties                                |
| [dumpPointRGBA](https://github.com/ZodmanPerth/aseprite-scripts/wiki/String-extensions-module#dumpPointRGBA)             | Returns a string representing the red, greed, blue, and alpha channels of the colour value of the passed point |
| [dumpPointRGBATable](https://github.com/ZodmanPerth/aseprite-scripts/wiki/String-extensions-module#dumpPointRGBATable)   | Returns a table containing the RGBA channels and the colour value of the point as properties                   |
| [dumpPointPosition](https://github.com/ZodmanPerth/aseprite-scripts/wiki/String-extensions-module#dumpPointPosition)     | Returns the x and y coordinates of the passed point as a comma separated string                                |
| [indent](https://github.com/ZodmanPerth/aseprite-scripts/wiki/String-extensions-module#indent)                           | Returns a string of spaces with the passed length                                                              |
| [isNilOrWhiteSpace](https://github.com/ZodmanPerth/aseprite-scripts/wiki/String-extensions-module#isNilOrWhiteSpace)     | Returns true if the passed parameter is a string that is either nil or only contains whitespace                |
| [printPoint](https://github.com/ZodmanPerth/aseprite-scripts/wiki/String-extensions-module#printPoint)                   | Prints the x and y coordinates of the passed point as a comma separated string                                 |
| [trim](https://github.com/ZodmanPerth/aseprite-scripts/wiki/String-extensions-module#trim)                               | Returns the passed string with all whitespace removed from the start and end                                   |



## [Lua Extensions](https://github.com/ZodmanPerth/aseprite-scripts/wiki/Lua-extensions-module)

Provides extended Lua functionality in Aseprite scripts.

### Functions

| Function                                                                                      | Description                                                                      |
| --------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| [clamp](https://github.com/ZodmanPerth/aseprite-scripts/wiki/Lua-extensions-module#clamp)     | Returns a value closest to the range between a minimum and maximum value         |
| [ternary](https://github.com/ZodmanPerth/aseprite-scripts/wiki/Lua-extensions-module#ternary) | Returns either the trueValue or the falseValue, depending on the condition value |