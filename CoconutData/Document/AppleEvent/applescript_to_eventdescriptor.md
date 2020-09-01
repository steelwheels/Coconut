# Translation resuls from AppleScript to AppleEventDescriptor

## About this page
This document describes about the setting of [NSAppleEventDescriptor](https://developer.apple.com/documentation/foundation/nsappleeventdescriptor) refrecting the souce code written by AppleScript.

## Copyright
This document is distributed under [GNU Free Documentation License](https://www.gnu.org/licenses/fdl-1.3.en.html).

## Translation results
### get property
#### AppleScript
````
tell application "JSTerminal"
	set bcolor to black
end tell
````

#### Event descriptor
````
'core'\'getd'{ '----':'obj '{ 'form':'prop', 'want':'prop', 'seld':'blak', 'from':null() }, &'csig':65536 }>
````

#### Returned descriptor by above event
````
'aevt'\'ansr'{ '----':'cRGB'($6...$), 'errn':0 }
````

### set property (color)
#### AppleScript
````
tell application "JSTerminal"
	set bolor to foreground color
end tell
````

#### Event descriptor
````
'core'\'setd'{ 'data':[ 28770, 26988, 29811 ], '----':'obj '{ 'form':'prop', 'want':'prop', 'seld':'fgcl', 'from':null() }, &'csig':65536 }
````

### new window
#### AppleScript
````
tell application "JSTerminal"
	make new window
end tell
````

#### Event descriptor
````
'core'\'crel'{ 'kocl':'docu', &'subj':null(), &'csig':65536 }
````

### set property (terminal width)
#### AppleScript
````
tell application "JSTerminal"
	set terminal width to 100
end tell
````

#### Event descriptor
````
'core'\'setd'{ 'data':100, '----':'obj '{ 'form':'prop', 'want':'prop', 'seld':'twdt', 'from':null() }, &'csig':65536 }
````

### set property (terminal height)
#### AppleScript
````
tell application "JSTerminal"
	set terminal height to 30
end
````

#### Event descriptor
````
'core'\'setd'{ 'data':30, '----':'obj '{ 'form':'prop', 'want':'prop', 'seld':'thgt', 'from':null() }, &'csig':65536 }
````

### close window
#### AppleScript (no argument)
````
tell application "JSTerminal"
	close window
end tell
````

#### Event descriptor
````
'core'\'clos'{ '----':'cwin', &'subj':null(), &'csig':65536 }
````

#### AppleScript (with window name)
````
tell application "JSTerminal"
	close window "a"
end tell
````

#### Event descriptor
````
'core'\'clos'{ '----':'obj '{ 'form':'name', 'want':'cwin', 'seld':'utxt'("a"), 'from':null() }, &'csig':65536 }
````

#### AppleScript (with window index)
````
tell application "JSTerminal"
	close window 1
end tell
````

#### Event descriptor
````
'core'\'clos'{ '----':'obj '{ 'form':'indx', 'want':'cwin', 'seld':1, 'from':null() }, &'csig':65536 }
````

### quit application
The Cocoa foundation decode it automatically.

#### EventDescriptor
````
`core`\`crel` {`kocl`:`cwin`, &`subj`:null(), &`csig`:65536}
````

# Related Links
* [Steel Wheels Project](https://steelwheels.github.io): The owner of this document.
* [Defihtions of event ID](http://frontierkernel.sourceforge.net/cgi-bin/lxr/source/Common/headers/macconv.h): Copyright (C) 1992-2004 UserLand Software, Inc.
