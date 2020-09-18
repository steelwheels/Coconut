# Contents of AppleEventDescriptor given by source AppleScript

## About this page
This document describes about the contents of [NSAppleEventDescriptor](https://developer.apple.com/documentation/foundation/nsappleeventdescriptor) with is given as execution result of source AppleScript.

## Copyright
This document is distributed under [GNU Free Documentation License](https://www.gnu.org/licenses/fdl-1.3.en.html).

## Translation results
### get property (color)
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

### get property (name of front document)
#### AppleScript
````
tell application "JSTerminal"
	set fname to name of front document
end tell
````

#### Event descriptor
````
'core'\'getd'{ '----':'obj '{ 'form':'prop', 'want':'prop', 'seld':'pnam', 'from':'obj '{ 'form':'indx', 'want':'docu', 'seld':1, 'from':null() } }, &'csig':65536 }
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

### set property (name of front window)
#### AppleScript
````
tell application "JSTerminal"
	set name of front document to "a.txt"
end tell
````

#### Event descriptor
````
'core'\'setd'{ 'data':'utxt'("a.txt"), '----':'obj '{ 'form':'prop', 'want':'prop', 'seld':'pnam', 'from':'obj '{ 'form':'indx', 'want':'docu', 'seld':1, 'from':null() } }, &'csig':65536 }
````

### activate
#### AppleScript
````
tell application "TextEdit"
	activate
end tell
````

#### Event descriptor
````
'misc'\'actv'{  }
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

### save document
#### AppleScript
````
set fpath to (((POSIX path of (path to users folder)) & "tomoo/tmp_dir/a.txt") as POSIX file)
save front document as text in fpath
````

#### Event descriptor
````
'core'\'save'{ 'fltp':'ctxt', 'kfil':"file:///Users/tomoo/tmp_dir/a.txt", '----':'obj '{ 'form':'indx', 'want':'docu', 'seld':1, 'from':null() }, &'csig':65536, &'shas':[ 'sbhs'("7bfa14215d92e5425ffa9a809aae178c74823641d59791bfc509d81ae9643600;00;00000000;00000000;00000000;0000000000000020;com.apple.app-sandbox.read-write;01;01000004;0000000204a221ab;01;/users/tomoo/tmp_dir/a.txt") ] }
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

### set property (text to front window)

#### AppleScript
````
tell application "JSTerminal"
	set text of front document to "Hello, world !!"
end tell
````

#### Event descriptor
`abso`($206C6C61$) = NSAppleEventDescriptor("abso", "all ")

````
'core'\'setd'{ 'data':'utxt'("Hello, world !!"), '----':'obj '{ 'form':'indx', 'want':'ctxt', 'seld':'abso'($206C6C61$), 'from':'obj '{ 'form':'indx', 'want':'docu', 'seld':1, 'from':null() } }, &'csig':65536 }
````

#### AppleScript
````
tell application "JSTerminal"
	set duptext to text of front document
end tell
````

#### Event descriptor
````
'core'\'crel'{ 'kocl':'docu', &'subj':null(), &'csig':65536 }
````

#### Ack from receiver
````
'aevt'\'ansr'{ '----':'obj '{ 'from':null(), 'want':'docu', 'form':'name', 'seld':'utxt'("RESULT_TEXT") } }
````

### quit application
The Cocoa foundation decode it automatically.

#### EventDescriptor
````
`core`\`crel` {`kocl`:`cwin`, &`subj`:null(), &`csig`:65536}
````

## Mail operation
### Make outgoing message
#### AppleScript
````
tell application "Mail"
	make new outgoing message
end tell
````

````
tell application "AppleEventChecker"
	activate
	set msg to make new outgoing message with properties {subject:"subject", sender:"tomoo", content:"content", visible:true, message signature:"steel.wheels.project"}
end tell
````

#### Event descriptor
````
'core'\'crel'{ 'kocl':'bcke', &'subj':null(), &'csig':65536 }
````

````
'core'\'crel'{ 'kocl':'bcke', 'prdt':{ 'subj':'utxt'("subject"), 'sndr':'utxt'("tomoo"), 'ctnt':'utxt'("content"), 'pvis':'true'("true"), 'tnrg':'utxt'("steel.wheels.project") }, &'subj':null(), &'csig':65536 }
````

## Safari operation
### Open URL
#### AppleScript
````
tell application "AppleEventChecker"
	tell window 1
		set URL of current tab to "https://steelwheels.github.io"
	end tell
	activate
end tell
````

#### Event descriptor
````
'core'\'setd'{ 'data':'utxt'("https://steelwheels.github.io"), '----':'obj '{ 'form':'prop', 'want':'prop', 'seld':'pURL', 'from':'obj '{ 'form':'prop', 'want':'prop', 'seld':'cTab', 'from':'obj '{ 'form':'indx', 'want':'cwin', 'seld':1, 'from':null() } } }, &'csig':65536 }
````

#### AppleScript
````
set newtab to make new tab of front window
````

````
'core'\'crel'{ 'kocl':'tab ', 'insh':'obj '{ 'form':'indx', 'want':'cwin', 'seld':1, 'from':null() }, &'csig':65536 }
````

# Related Links
* [Steel Wheels Project](https://steelwheels.github.io): The owner of this document.
* [Defihtions of event ID](http://frontierkernel.sourceforge.net/cgi-bin/lxr/source/Common/headers/macconv.h): Copyright (C) 1992-2004 UserLand Software, Inc.
