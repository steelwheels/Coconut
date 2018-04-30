# Exit code
## Introduction
This document define the exit code which is defined as `CNExitCode` in the  [CoconutData Framework](https://github.com/steelwheels/Coconut/tree/master/CoconutData).

## Exit code
|Code               | Value | Description               |
|:--                |:--    |:--                        |
|No error           |0      |Exit without any errors    |
|Internal error     |1      |Internal error caused by the bug|
|CommandLine error  |2      |Invalid command line options or arguments|
|Syntax error       |3      |Syntax or semantics error when some script or command file are parsed|
|Execution error    |4      |Runtime error |
|Exception          |5      |Runtime Exception      |

## Related link
* [Coconut Data Framework](https://github.com/steelwheels/Coconut/blob/master/CoconutData/README.md): The framework contains this definition.
* [Steel Wheels Project](http://steelwheels.github.io): Web site of developer.
