# Cocoa Scripting Support
The application can be controlled by external application's script like AppleScript.

## Properties
Following properties can be accessed to control the application.

|Property name      |Data type  |Description            |
|:--                |:--        |:--                    |
|`foreground color` |Color (NSColor)    |Color of the text    |
|`background color` |Color (NSColor)    |Background color of the text field. |

The properties are defined by `.sdef`. It is implemented at [CoconutScript.sdef](https://github.com/steelwheels/Coconut/blob/master/CoconutScript/Resource/CoconutScript.sdef) file.

## Sample script
This is sample script written by AppleScript:
````
tell application "JSTerminal"
  set foreground color to green
  set background color to black
end tell
````

## Related links
* [CoconutScript](https://github.com/steelwheels/Coconut/tree/master/CoconutScript): The macOS framework to support Cocoa Scripting.
* [Steel Wheels Project](http://steelwheels.github.io): The developer of this software and document.