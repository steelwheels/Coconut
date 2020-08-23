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

### set property
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

### open window

### close window

### quit application

#### EventDescriptor
````
`core`\`crel` {`kocl`:`cwin`, &`subj`:null(), &`csig`:65536}
````

# Related Links
* [Steel Wheels Project](https://steelwheels.github.io): The owner of this document.
* [Defihtions of event ID](http://frontierkernel.sourceforge.net/cgi-bin/lxr/source/Common/headers/macconv.h): Copyright (C) 1992-2004 UserLand Software, Inc. 
