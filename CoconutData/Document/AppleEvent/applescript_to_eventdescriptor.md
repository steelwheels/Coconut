# Translation resuls from AppleScript to AppleEventDescriptor

## About this page
This document describes about the setting of [NSAppleEventDescriptor](https://developer.apple.com/documentation/foundation/nsappleeventdescriptor) refrecting the souce code written by AppleScript.

## Copyright
This document is distributed under [GNU Free Documentation License](https://www.gnu.org/licenses/fdl-1.3.en.html).

## Translation results
### new window
#### AppleScript
````
tell application "JSTerminal"
	make new window
end tell
````

#### EventDescriptor
````
`core`\`crel` {`kocl`:`cwin`, &`subj`:null(), &`csig`:65536}
````

# Related Links
* [Steel Wheels Project](https://steelwheels.github.io): The owner of this document.
