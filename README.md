# aseprite-scripts

This repo contains custom scripts for use in Aseprite.





<br></br>
# Installation

Copy the contents of the `scripts` folder to your Aseprite scripts folder.  
[How to locate the Aseprite scripts folder?](https://community.aseprite.org/t/locate-user-scripts-folder/2170)





<br></br>
# Scripts

This repo currently contains only a single script but more will be added over time.  See the [wiki](https://github.com/ZodmanPerth/aseprite-scripts/wiki) for additional details.

Below is an outline of the scripts that can be used through Aseprite.

## Colour selected pixels

Provides a dialog for the user to set/adjust the RGBA colour channels of selected pixels on an image.  It was developed mainly as a working example of the RGBA custom widget in the [custom widget module](#custom-widgets).

### Features
* Allows single or multiple selections for modification.
* Pixels with no alpha value (transparent) can be opted in or out of the change (defaults to out).
* The value can be modified with a slider or a numeric text box.
* The dialog remembers and restores the values when toggling between absolute and relative modes.
* The result of the operation are previewed live on the image and can be cancelled.
* The accepted results are undoable/redoable.  Undo history contains a single event for the operation..
* The RGBA and operation buttons on the dialog have tooltips that explain the state of the dialog when hovering.

### Demo
<img src="assets/screenshots/colour-selected-pixels/demo.gif?v2024-12-08" style="margin-left:20;width:100%;max-width:400">




<br></br>
# Modules

To support the scripts a number of modules have been created.  These modules contain additional functionality to ensure script code can focus purely on setup and execution of script features.

See the [wiki](https://github.com/ZodmanPerth/aseprite-scripts/wiki) for more information about each module.



## Custom Widgets

Contains custom widgets that can be used on a canvas in a dialog.  Kudos for the idea goes to the Aseprite team's [Custom Widget Example](https://github.com/aseprite/Aseprite-Script-Examples/blob/main/Custom%20Widgets.lua).

### Widgets
* Label
* Button (including toggle variant)
* RGBA (and operation) button cluster
* Tooltip (though it's not reusable outside custom widgets at present)



## Selection Extensions

Provides functions for working with selections in Aseprite.

### Functions

* Iterate Selection



## Binding Extensions

Provides functionality that binds widgets together so their properties automatically affect one another.

### Features

* Dialog to Custom Widgets module
* Slider to Number text box


## String Extensions

Provides functions for working with strings in Aseprite scripts.

### Features

| Function            | Description                                                                                                    |
| ------------------- | -------------------------------------------------------------------------------------------------------------- |
| concatWithCommas    | Returns all the passed parameters concatenated together with "," as a separator                                |
| concatWithSeparator | Returns all the passed parameters concatenated together with the first parameter as a separator                |
| dumpTable           | Returns the passed table as a multiline and indented string suitable for printing                              |
| dumpColourRGBA      | Returns a string representing the red, greed, blue, and alpha channels of the passed Colour                    |
| dumpColourRGBATable | Returns a table containing the RGBA channels and the passed Color as properties                                |
| dumpPointRGBA       | Returns a string representing the red, greed, blue, and alpha channels of the colour value of the passed point |
| dumpPointRGBATable  | Returns a table containing the RGBA channels and the colour value of the point as properties                   |
| dumpPointPosition   | Returns the x and y coordinates of the passed point as a comma separated string                                |
| indent              | Returns a string of spaces with the passed length                                                              |
| isNilOrWhiteSpace   | Returns true if the passed parameter is a string that is either nil or only contains whitespace                |
| printPoint          | Prints the x and y coordinates of the passed point as a comma separated string                                 |
| trim                | Returns the passed string with all whitespace removed from the start and end                                   |



## Lua Extensions

Provides extended Lua functionality in Aseprite scripts.

### Features

| Function | Description                                                                      |
| -------- | -------------------------------------------------------------------------------- |
| clamp    | Returns a value closest to the range between a minimum and maximum value         |
| ternary  | Returns either the trueValue or the falseValue, depending on the condition value |