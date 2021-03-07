# Overview of CoconutData framework

## Thread design
### Thread controller
Following functions are used to create main/user threads.
* `CNExecuteInMainThread`
* `CNExecuteInUserThread`

For more details, see the implementation [CNThread.swift](https://github.com/steelwheels/Coconut/blob/master/CoconutData/Source/Process/CNThread.swift).

### User thread
[CNThread class](https://github.com/steelwheels/Coconut/blob/master/CoconutData/Source/Process/CNThread.swift) execute the main function in user thread.


# References
* [Steel Wheels Project](https://steelwheels.github.io): The owner of this project
* [Coconut Frameworks](https://github.com/steelwheels/Coconut/blob/master/README.md): The package which contains this Framework

